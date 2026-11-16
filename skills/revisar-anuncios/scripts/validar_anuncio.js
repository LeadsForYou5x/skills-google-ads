// Valida anúncios responsivos (RSA) e recursos da campanha nas regras do método do Matheus.
// Mesma lógica do validar_anuncio.py, pra Mac sem Python (roda com o osascript, que já vem no macOS).
//
// Uso: osascript -l JavaScript validar_anuncio.js anuncios.json
// A última linha diz "Resultado: aprovado" ou quantos erros corrigir. AVISO não bloqueia.
ObjC.import('Foundation');

var LIM_TITULO = 30, LIM_DESCRICAO = 90, LIM_CAMINHO = 15;
var N_TITULOS = 15, N_DESCRICOES = 4;
var TITULO_FINAL = '[Recomendado]';
var LIM_SITELINK = 25, LIM_SITELINK_DESC = 35, LIM_FRASE = 25, LIM_SNIPPET = 25, LIM_PRECO = 25;
var IDEAL_SITELINKS = 6, IDEAL_FRASES = 8, IDEAL_SNIPPETS = 2;
// Cabeçalhos que a API aceitou no lote (testados). "Bairros" está na lista do Google, mas a API recusa.
var CABECALHOS = ['servicos', 'tipos'];

function normalizar(texto) {
  return texto.normalize('NFKD').replace(/[̀-ͯ]/g, '').toLowerCase().split(/\s+/).filter(Boolean).join(' ');
}

function palavrasMinusculas(titulo) {
  return titulo.split(/\s+/).filter(function (p) {
    var c = p.charAt(0);
    var ehLetra = c.toLowerCase() !== c.toUpperCase();
    return ehLetra && c === c.toLowerCase();
  });
}

function validarGrupo(g) {
  var erros = [], avisos = [];
  var titulos = (g.titulos || []).map(function (t) { return t.trim(); });
  var descricoes = (g.descricoes || []).map(function (d) { return d.trim(); });

  if (titulos.length !== N_TITULOS) erros.push(titulos.length + ' títulos (precisa de ' + N_TITULOS + ')');
  if (descricoes.length !== N_DESCRICOES) erros.push(descricoes.length + ' descrições (precisa de ' + N_DESCRICOES + ')');
  if (!titulos.length || titulos[titulos.length - 1] !== TITULO_FINAL) erros.push('o último título precisa ser exatamente "' + TITULO_FINAL + '"');
  if (titulos.filter(function (t) { return t === TITULO_FINAL; }).length > 1) erros.push('"' + TITULO_FINAL + '" aparece mais de uma vez');

  titulos.forEach(function (t) {
    if (t.length > LIM_TITULO) erros.push('título com ' + t.length + ' caracteres (máx ' + LIM_TITULO + '): "' + t + '"');
    if (t.indexOf('!') !== -1) erros.push('título com exclamação (o Google reprova): "' + t + '"');
    var minusculas = palavrasMinusculas(t);
    if (minusculas.length) erros.push('título fora do padrão Maiúscula No Início De Cada Palavra (' + minusculas.join(', ') + '): "' + t + '"');
    if (t === t.toUpperCase() && t !== t.toLowerCase() && t.length > 4) avisos.push('título todo em caixa alta: "' + t + '"');
  });
  descricoes.forEach(function (d) {
    if (d.length > LIM_DESCRICAO) erros.push('descrição com ' + d.length + ' caracteres (máx ' + LIM_DESCRICAO + '): "' + d + '"');
  });

  var vistos = {};
  titulos.concat(descricoes).forEach(function (t) {
    var chave = normalizar(t);
    if (vistos[chave]) erros.push('texto repetido: "' + t + '"');
    vistos[chave] = true;
  });

  var palavra = normalizar(g.palavra_principal || '');
  if (palavra) {
    var comPalavra = titulos.filter(function (t) { return normalizar(t).indexOf(palavra) !== -1; }).length;
    if (comPalavra === 0) erros.push('nenhum título contém a palavra do grupo "' + g.palavra_principal + '"');
    else if (comPalavra === 1) avisos.push('só 1 título com a palavra do grupo (o ideal é 2 ou mais)');
  } else {
    avisos.push('sem "palavra_principal" informada: não deu pra conferir a palavra nos títulos');
  }

  ['path1', 'path2'].forEach(function (campo) {
    var caminho = g[campo] || '';
    if (caminho.length > LIM_CAMINHO) erros.push(campo + ' com ' + caminho.length + ' caracteres (máx ' + LIM_CAMINHO + '): "' + caminho + '"');
    if (caminho && normalizar(caminho) !== caminho.toLowerCase()) avisos.push(campo + ' com acento ou espaço: "' + caminho + '"');
  });
  if (g.path2 && !g.path1) erros.push('path2 preenchido sem path1');

  var url = g.url || '';
  if (url.indexOf('https://') !== 0) erros.push('link final precisa começar com https:// (veio "' + url + '")');

  var fixados = (g.titulos_fixados || []).filter(function (t) { return t; }).length;
  if (fixados > 1) avisos.push(fixados + ' títulos fixados (o ideal é no máximo 1)');

  return { erros: erros, avisos: avisos };
}

function validarRecursos(r) {
  var erros = [], avisos = [];

  var sitelinks = r.sitelinks || [];
  if (sitelinks.length < 4) erros.push(sitelinks.length + ' sitelinks (mínimo 4, o ideal é ' + IDEAL_SITELINKS + ')');
  else if (sitelinks.length < IDEAL_SITELINKS) avisos.push(sitelinks.length + ' sitelinks (o ideal é ' + IDEAL_SITELINKS + ')');
  var textos = {}, urls = {};
  sitelinks.forEach(function (s) {
    var texto = (s.texto || '').trim(), d1 = (s.descricao1 || '').trim(), d2 = (s.descricao2 || '').trim();
    var url = (s.url || '').trim();
    if (!texto || texto.length > LIM_SITELINK) erros.push('sitelink com ' + texto.length + ' caracteres no nome (de 1 a ' + LIM_SITELINK + '): "' + texto + '"');
    if (!d1 || !d2) erros.push('sitelink sem as 2 descrições (curta e longa): "' + texto + '"');
    [d1, d2].forEach(function (d) {
      if (d.length > LIM_SITELINK_DESC) erros.push('descrição de sitelink com ' + d.length + ' caracteres (máx ' + LIM_SITELINK_DESC + '): "' + d + '"');
    });
    if (url.indexOf('https://') !== 0) erros.push('sitelink "' + texto + '" com link que não começa com https:// (veio "' + url + '")');
    if (textos[normalizar(texto)]) erros.push('nome de sitelink repetido: "' + texto + '"');
    textos[normalizar(texto)] = true;
    if (urls[url]) erros.push('link de sitelink repetido: "' + url + '" (use o hack do Matheus: a mesma página com #1, #2, #3...)');
    urls[url] = true;
  });

  var frases = (r.frases || []).map(function (f) { return f.trim(); });
  if (frases.length < 4) erros.push(frases.length + ' frases de destaque (mínimo 4, o ideal é ' + IDEAL_FRASES + ')');
  else if (frases.length < IDEAL_FRASES) avisos.push(frases.length + ' frases de destaque (o ideal é ' + IDEAL_FRASES + ')');
  var vistas = {};
  frases.forEach(function (f) {
    if (f.length > LIM_FRASE) erros.push('frase de destaque com ' + f.length + ' caracteres (máx ' + LIM_FRASE + '): "' + f + '"');
    if (f.indexOf('!') !== -1) erros.push('frase de destaque com exclamação (o Google reprova): "' + f + '"');
    if (vistas[normalizar(f)]) erros.push('frase de destaque repetida: "' + f + '"');
    vistas[normalizar(f)] = true;
  });

  var snippets = r.snippets || [];
  if (!snippets.length) erros.push('nenhum snippet estruturado');
  else if (snippets.length < IDEAL_SNIPPETS) avisos.push(snippets.length + ' snippet (o ideal são ' + IDEAL_SNIPPETS + ' cabeçalhos diferentes)');
  snippets.forEach(function (sn) {
    var cab = (sn.cabecalho || '').trim();
    var valores = (sn.valores || []).map(function (v) { return v.trim(); });
    if (CABECALHOS.indexOf(normalizar(cab)) === -1) erros.push('cabeçalho de snippet que a API não aceita: "' + cab + '" (use Serviços ou Tipos; Bairros é recusado)');
    if (valores.length < 3 || valores.length > 10) erros.push('snippet "' + cab + '" com ' + valores.length + ' valores (de 3 a 10)');
    else if (valores.length < 4) avisos.push('snippet "' + cab + '" com 3 valores (o ideal é 4 ou mais)');
    valores.forEach(function (v) {
      if (v.length > LIM_SNIPPET) erros.push('valor de snippet com ' + v.length + ' caracteres (máx ' + LIM_SNIPPET + '): "' + v + '"');
    });
  });

  if (!(r.telefone || '').trim()) avisos.push('sem telefone: fica sem o recurso de ligação (ok se o negócio não atende ligação)');

  var precos = r.precos || [];
  if (precos.length) {
    if (precos.length < 3 || precos.length > 8) erros.push(precos.length + ' itens de preço (de 3 a 8)');
    precos.forEach(function (p) {
      ['titulo', 'descricao'].forEach(function (campo) {
        var texto = (p[campo] || '').trim();
        if (!texto || texto.length > LIM_PRECO) erros.push('preço com ' + campo + ' de ' + texto.length + ' caracteres (de 1 a ' + LIM_PRECO + '): "' + texto + '"');
      });
      if (typeof p.valor !== 'number' || p.valor <= 0) erros.push('preço sem valor numérico: "' + (p.titulo || '') + '"');
      if ((p.url || '').indexOf('https://') !== 0) erros.push('preço "' + (p.titulo || '') + '" com link que não começa com https://');
    });
  }

  return { erros: erros, avisos: avisos };
}

function run(argv) {
  if (argv.length !== 1) return 'Uso: osascript -l JavaScript validar_anuncio.js anuncios.json';
  var texto = $.NSString.stringWithContentsOfFileEncodingError(argv[0], $.NSUTF8StringEncoding, null);
  if (!texto) return 'ERRO: não consegui ler o arquivo ' + argv[0];
  var dados = JSON.parse(ObjC.unwrap(texto));

  var linhas = [], totalErros = 0;
  (dados.grupos || []).forEach(function (g) {
    var r = validarGrupo(g);
    linhas.push('');
    linhas.push('== ' + (g.campanha || '') + ' › ' + (g.grupo || '?') + ': ' + (r.erros.length ? r.erros.length + ' ERRO(S)' : 'OK'));
    r.erros.forEach(function (e) { linhas.push('  ERRO  ' + e); });
    r.avisos.forEach(function (a) { linhas.push('  AVISO ' + a); });
    totalErros += r.erros.length;
  });
  (dados.recursos || []).forEach(function (rec) {
    var r = validarRecursos(rec);
    linhas.push('');
    linhas.push('== Recursos · ' + (rec.campanha || '') + ': ' + (r.erros.length ? r.erros.length + ' ERRO(S)' : 'OK'));
    r.erros.forEach(function (e) { linhas.push('  ERRO  ' + e); });
    r.avisos.forEach(function (a) { linhas.push('  AVISO ' + a); });
    totalErros += r.erros.length;
  });
  linhas.push('');
  linhas.push('Resultado: ' + (totalErros === 0 ? 'aprovado' : totalErros + ' erro(s) pra corrigir'));
  return linhas.join('\n');
}
