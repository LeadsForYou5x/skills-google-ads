# Valida anúncios responsivos (RSA) e recursos da campanha nas regras do método do Matheus.
# Mesma lógica do validar_anuncio.py, pra Windows sem Python (roda no PowerShell, que já vem no Windows).
#
# Uso: powershell -NoProfile -ExecutionPolicy Bypass -File validar_anuncio.ps1 anuncios.json
# Sai com código 1 se houver ERRO. AVISO não bloqueia.
param([Parameter(Mandatory = $true)][string]$Arquivo)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$LIM_TITULO = 30; $LIM_DESCRICAO = 90; $LIM_CAMINHO = 15
$N_TITULOS = 15; $N_DESCRICOES = 4
$TITULO_FINAL = '[Recomendado]'
$LIM_SITELINK = 25; $LIM_SITELINK_DESC = 35; $LIM_FRASE = 25; $LIM_SNIPPET = 25; $LIM_PRECO = 25
$IDEAL_SITELINKS = 6; $IDEAL_FRASES = 8; $IDEAL_SNIPPETS = 2
# Cabeçalhos que a API aceitou no lote (testados). "Bairros" está na lista do Google, mas a API recusa.
$CABECALHOS = @('servicos', 'tipos')

function Texto($valor) {
  if ($null -eq $valor) { return '' }
  return ([string]$valor).Trim()
}

function Normalizar([string]$texto) {
  $decomposto = $texto.Normalize([Text.NormalizationForm]::FormKD)
  $sb = New-Object System.Text.StringBuilder
  foreach ($c in $decomposto.ToCharArray()) {
    if ([Globalization.CharUnicodeInfo]::GetUnicodeCategory($c) -ne [Globalization.UnicodeCategory]::NonSpacingMark) {
      [void]$sb.Append($c)
    }
  }
  $partes = $sb.ToString().ToLowerInvariant() -split '\s+' | Where-Object { $_ -ne '' }
  return ($partes -join ' ')
}

function PalavrasMinusculas([string]$titulo) {
  $resultado = @()
  foreach ($p in ($titulo -split '\s+' | Where-Object { $_ -ne '' })) {
    $c = $p[0]
    if ([char]::IsLetter($c) -and [char]::IsLower($c)) { $resultado += $p }
  }
  return , $resultado
}

function ValidarGrupo($g) {
  $erros = New-Object System.Collections.Generic.List[string]
  $avisos = New-Object System.Collections.Generic.List[string]
  $titulos = @(); if ($g.titulos) { $titulos = @($g.titulos | ForEach-Object { Texto $_ }) }
  $descricoes = @(); if ($g.descricoes) { $descricoes = @($g.descricoes | ForEach-Object { Texto $_ }) }

  if ($titulos.Count -ne $N_TITULOS) { $erros.Add("$($titulos.Count) títulos (precisa de $N_TITULOS)") }
  if ($descricoes.Count -ne $N_DESCRICOES) { $erros.Add("$($descricoes.Count) descrições (precisa de $N_DESCRICOES)") }
  if ($titulos.Count -eq 0 -or $titulos[$titulos.Count - 1] -cne $TITULO_FINAL) { $erros.Add("o último título precisa ser exatamente `"$TITULO_FINAL`"") }
  if (@($titulos | Where-Object { $_ -ceq $TITULO_FINAL }).Count -gt 1) { $erros.Add("`"$TITULO_FINAL`" aparece mais de uma vez") }

  foreach ($t in $titulos) {
    if ($t.Length -gt $LIM_TITULO) { $erros.Add("título com $($t.Length) caracteres (máx $LIM_TITULO): `"$t`"") }
    if ($t.Contains('!')) { $erros.Add("título com exclamação (o Google reprova): `"$t`"") }
    $minusculas = PalavrasMinusculas $t
    if ($minusculas.Count -gt 0) { $erros.Add("título fora do padrão Maiúscula No Início De Cada Palavra ($($minusculas -join ', ')): `"$t`"") }
    if (($t -ceq $t.ToUpperInvariant()) -and ($t -cne $t.ToLowerInvariant()) -and $t.Length -gt 4) { $avisos.Add("título todo em caixa alta: `"$t`"") }
  }
  foreach ($d in $descricoes) {
    if ($d.Length -gt $LIM_DESCRICAO) { $erros.Add("descrição com $($d.Length) caracteres (máx $LIM_DESCRICAO): `"$d`"") }
  }

  $vistos = @{}
  foreach ($t in ($titulos + $descricoes)) {
    $chave = Normalizar $t
    if ($vistos.ContainsKey($chave)) { $erros.Add("texto repetido: `"$t`"") }
    $vistos[$chave] = $true
  }

  $palavra = Normalizar (Texto $g.palavra_principal)
  if ($palavra) {
    $comPalavra = @($titulos | Where-Object { (Normalizar $_).Contains($palavra) }).Count
    if ($comPalavra -eq 0) { $erros.Add("nenhum título contém a palavra do grupo `"$($g.palavra_principal)`"") }
    elseif ($comPalavra -eq 1) { $avisos.Add('só 1 título com a palavra do grupo (o ideal é 2 ou mais)') }
  }
  else {
    $avisos.Add('sem "palavra_principal" informada: não deu pra conferir a palavra nos títulos')
  }

  foreach ($campo in @('path1', 'path2')) {
    $caminho = Texto $g.$campo
    if ($caminho.Length -gt $LIM_CAMINHO) { $erros.Add("$campo com $($caminho.Length) caracteres (máx $LIM_CAMINHO): `"$caminho`"") }
    if ($caminho -and ((Normalizar $caminho) -cne $caminho.ToLowerInvariant())) { $avisos.Add("$campo com acento ou espaço: `"$caminho`"") }
  }
  if ((Texto $g.path2) -and -not (Texto $g.path1)) { $erros.Add('path2 preenchido sem path1') }

  $url = Texto $g.url
  if (-not $url.StartsWith('https://')) { $erros.Add("link final precisa começar com https:// (veio `"$url`")") }

  $fixados = 0; if ($g.titulos_fixados) { $fixados = @($g.titulos_fixados | Where-Object { $_ }).Count }
  if ($fixados -gt 1) { $avisos.Add("$fixados títulos fixados (o ideal é no máximo 1)") }

  return @{ erros = $erros; avisos = $avisos }
}

function ValidarRecursos($r) {
  $erros = New-Object System.Collections.Generic.List[string]
  $avisos = New-Object System.Collections.Generic.List[string]

  $sitelinks = @(); if ($r.sitelinks) { $sitelinks = @($r.sitelinks) }
  if ($sitelinks.Count -lt 4) { $erros.Add("$($sitelinks.Count) sitelinks (mínimo 4, o ideal é $IDEAL_SITELINKS)") }
  elseif ($sitelinks.Count -lt $IDEAL_SITELINKS) { $avisos.Add("$($sitelinks.Count) sitelinks (o ideal é $IDEAL_SITELINKS)") }
  $textos = @{}; $urls = @{}
  foreach ($s in $sitelinks) {
    $texto = Texto $s.texto; $d1 = Texto $s.descricao1; $d2 = Texto $s.descricao2; $url = Texto $s.url
    if (-not $texto -or $texto.Length -gt $LIM_SITELINK) { $erros.Add("sitelink com $($texto.Length) caracteres no nome (de 1 a $LIM_SITELINK): `"$texto`"") }
    if (-not $d1 -or -not $d2) { $erros.Add("sitelink sem as 2 descrições (curta e longa): `"$texto`"") }
    foreach ($d in @($d1, $d2)) {
      if ($d.Length -gt $LIM_SITELINK_DESC) { $erros.Add("descrição de sitelink com $($d.Length) caracteres (máx $LIM_SITELINK_DESC): `"$d`"") }
    }
    if (-not $url.StartsWith('https://')) { $erros.Add("sitelink `"$texto`" com link que não começa com https:// (veio `"$url`")") }
    $chave = Normalizar $texto
    if ($textos.ContainsKey($chave)) { $erros.Add("nome de sitelink repetido: `"$texto`"") }
    $textos[$chave] = $true
    if ($urls.ContainsKey($url)) { $erros.Add("link de sitelink repetido: `"$url`" (use o hack do Matheus: a mesma página com #1, #2, #3...)") }
    $urls[$url] = $true
  }

  $frases = @(); if ($r.frases) { $frases = @($r.frases | ForEach-Object { Texto $_ }) }
  if ($frases.Count -lt 4) { $erros.Add("$($frases.Count) frases de destaque (mínimo 4, o ideal é $IDEAL_FRASES)") }
  elseif ($frases.Count -lt $IDEAL_FRASES) { $avisos.Add("$($frases.Count) frases de destaque (o ideal é $IDEAL_FRASES)") }
  $vistas = @{}
  foreach ($f in $frases) {
    if ($f.Length -gt $LIM_FRASE) { $erros.Add("frase de destaque com $($f.Length) caracteres (máx $LIM_FRASE): `"$f`"") }
    if ($f.Contains('!')) { $erros.Add("frase de destaque com exclamação (o Google reprova): `"$f`"") }
    $chave = Normalizar $f
    if ($vistas.ContainsKey($chave)) { $erros.Add("frase de destaque repetida: `"$f`"") }
    $vistas[$chave] = $true
  }

  $snippets = @(); if ($r.snippets) { $snippets = @($r.snippets) }
  if ($snippets.Count -eq 0) { $erros.Add('nenhum snippet estruturado') }
  elseif ($snippets.Count -lt $IDEAL_SNIPPETS) { $avisos.Add("$($snippets.Count) snippet (o ideal são $IDEAL_SNIPPETS cabeçalhos diferentes)") }
  foreach ($sn in $snippets) {
    $cab = Texto $sn.cabecalho
    $valores = @(); if ($sn.valores) { $valores = @($sn.valores | ForEach-Object { Texto $_ }) }
    if ($CABECALHOS -notcontains (Normalizar $cab)) { $erros.Add("cabeçalho de snippet que a API não aceita: `"$cab`" (use Serviços ou Tipos; Bairros é recusado)") }
    if ($valores.Count -lt 3 -or $valores.Count -gt 10) { $erros.Add("snippet `"$cab`" com $($valores.Count) valores (de 3 a 10)") }
    elseif ($valores.Count -lt 4) { $avisos.Add("snippet `"$cab`" com 3 valores (o ideal é 4 ou mais)") }
    foreach ($v in $valores) {
      if ($v.Length -gt $LIM_SNIPPET) { $erros.Add("valor de snippet com $($v.Length) caracteres (máx $LIM_SNIPPET): `"$v`"") }
    }
  }

  if (-not (Texto $r.telefone)) { $avisos.Add('sem telefone: fica sem o recurso de ligação (ok se o negócio não atende ligação)') }

  $precos = @(); if ($r.precos) { $precos = @($r.precos) }
  if ($precos.Count -gt 0) {
    if ($precos.Count -lt 3 -or $precos.Count -gt 8) { $erros.Add("$($precos.Count) itens de preço (de 3 a 8)") }
    foreach ($p in $precos) {
      foreach ($campo in @('titulo', 'descricao')) {
        $texto = Texto $p.$campo
        if (-not $texto -or $texto.Length -gt $LIM_PRECO) { $erros.Add("preço com $campo de $($texto.Length) caracteres (de 1 a $LIM_PRECO): `"$texto`"") }
      }
      $valor = $p.valor
      $ehNumero = ($valor -is [int]) -or ($valor -is [long]) -or ($valor -is [double]) -or ($valor -is [decimal])
      if (-not $ehNumero -or $valor -le 0) { $erros.Add("preço sem valor numérico: `"$(Texto $p.titulo)`"") }
      if (-not (Texto $p.url).StartsWith('https://')) { $erros.Add("preço `"$(Texto $p.titulo)`" com link que não começa com https://") }
    }
  }

  return @{ erros = $erros; avisos = $avisos }
}

$dados = Get-Content -Raw -Encoding UTF8 -Path $Arquivo | ConvertFrom-Json
$totalErros = 0

$grupos = @(); if ($dados.grupos) { $grupos = @($dados.grupos) }
$recursos = @(); if ($dados.recursos) { $recursos = @($dados.recursos) }

foreach ($g in $grupos) {
  $r = ValidarGrupo $g
  $status = if ($r.erros.Count) { "$($r.erros.Count) ERRO(S)" } else { 'OK' }
  Write-Output ''
  Write-Output "== $(Texto $g.campanha) › $(Texto $g.grupo): $status"
  foreach ($e in $r.erros) { Write-Output "  ERRO  $e" }
  foreach ($a in $r.avisos) { Write-Output "  AVISO $a" }
  $totalErros += $r.erros.Count
}

foreach ($rec in $recursos) {
  $r = ValidarRecursos $rec
  $status = if ($r.erros.Count) { "$($r.erros.Count) ERRO(S)" } else { 'OK' }
  Write-Output ''
  Write-Output "== Recursos · $(Texto $rec.campanha): $status"
  foreach ($e in $r.erros) { Write-Output "  ERRO  $e" }
  foreach ($a in $r.avisos) { Write-Output "  AVISO $a" }
  $totalErros += $r.erros.Count
}

Write-Output ''
if ($totalErros -eq 0) { Write-Output 'Resultado: aprovado' } else { Write-Output "Resultado: $totalErros erro(s) pra corrigir" }
if ($totalErros -gt 0) { exit 1 }
