#!/usr/bin/env python3
"""Valida anúncios responsivos (RSA) e recursos da campanha nas regras do método do Matheus.

Uso: python3 validar_anuncio.py anuncios.json
Sai com código 1 se houver ERRO. AVISO não bloqueia.
"""
import json
import sys
import unicodedata

LIM_TITULO, LIM_DESCRICAO, LIM_CAMINHO = 30, 90, 15
N_TITULOS, N_DESCRICOES = 15, 4
TITULO_FINAL = "[Recomendado]"
LIM_SITELINK, LIM_SITELINK_DESC, LIM_FRASE, LIM_SNIPPET, LIM_PRECO = 25, 35, 25, 25, 25
IDEAL_SITELINKS, IDEAL_FRASES, IDEAL_SNIPPETS = 6, 8, 2
# Cabeçalhos que a API aceitou no lote (testados). "Bairros" está na lista do Google, mas a API recusa (INVALID_FORMAT).
CABECALHOS = {"servicos", "tipos"}


def normalizar(texto):
    sem_acento = unicodedata.normalize("NFKD", texto).encode("ascii", "ignore").decode()
    return " ".join(sem_acento.lower().split())


def palavras_minusculas(titulo):
    return [p for p in titulo.split() if p[:1].isalpha() and not p[:1].isupper()]


def validar_grupo(g):
    erros, avisos = [], []
    nome = g.get("grupo", "?")
    titulos = [t.strip() for t in g.get("titulos", [])]
    descricoes = [d.strip() for d in g.get("descricoes", [])]

    if len(titulos) != N_TITULOS:
        erros.append(f"{len(titulos)} títulos (precisa de {N_TITULOS})")
    if len(descricoes) != N_DESCRICOES:
        erros.append(f"{len(descricoes)} descrições (precisa de {N_DESCRICOES})")
    if not titulos or titulos[-1] != TITULO_FINAL:
        erros.append(f"o último título precisa ser exatamente \"{TITULO_FINAL}\"")
    if titulos.count(TITULO_FINAL) > 1:
        erros.append(f"\"{TITULO_FINAL}\" aparece mais de uma vez")

    for t in titulos:
        if len(t) > LIM_TITULO:
            erros.append(f"título com {len(t)} caracteres (máx {LIM_TITULO}): \"{t}\"")
        if "!" in t:
            erros.append(f"título com exclamação (o Google reprova): \"{t}\"")
        minusculas = palavras_minusculas(t)
        if minusculas:
            erros.append(f"título fora do padrão Maiúscula No Início De Cada Palavra ({', '.join(minusculas)}): \"{t}\"")
        if t.isupper() and len(t) > 4:
            avisos.append(f"título todo em caixa alta: \"{t}\"")
    for d in descricoes:
        if len(d) > LIM_DESCRICAO:
            erros.append(f"descrição com {len(d)} caracteres (máx {LIM_DESCRICAO}): \"{d}\"")

    vistos = {}
    for t in titulos + descricoes:
        chave = normalizar(t)
        if chave in vistos:
            erros.append(f"texto repetido: \"{t}\"")
        vistos[chave] = True

    palavra = normalizar(g.get("palavra_principal", ""))
    if palavra:
        com_palavra = sum(1 for t in titulos if palavra in normalizar(t))
        if com_palavra == 0:
            erros.append(f"nenhum título contém a palavra do grupo \"{g['palavra_principal']}\"")
        elif com_palavra == 1:
            avisos.append("só 1 título com a palavra do grupo (o ideal é 2 ou mais)")
    else:
        avisos.append("sem \"palavra_principal\" informada: não deu pra conferir a palavra nos títulos")

    for campo in ("path1", "path2"):
        caminho = g.get(campo, "")
        if len(caminho) > LIM_CAMINHO:
            erros.append(f"{campo} com {len(caminho)} caracteres (máx {LIM_CAMINHO}): \"{caminho}\"")
        if caminho and normalizar(caminho) != caminho.lower():
            avisos.append(f"{campo} com acento ou espaço: \"{caminho}\"")
    if g.get("path2") and not g.get("path1"):
        erros.append("path2 preenchido sem path1")

    url = g.get("url", "")
    if not url.startswith("https://"):
        erros.append(f"link final precisa começar com https:// (veio \"{url}\")")

    fixados = sum(1 for t in g.get("titulos_fixados", []) if t)
    if fixados > 1:
        avisos.append(f"{fixados} títulos fixados (o ideal é no máximo 1)")

    return nome, erros, avisos


def validar_recursos(r):
    erros, avisos = [], []

    sitelinks = r.get("sitelinks", [])
    if len(sitelinks) < 4:
        erros.append(f"{len(sitelinks)} sitelinks (mínimo 4, o ideal é {IDEAL_SITELINKS})")
    elif len(sitelinks) < IDEAL_SITELINKS:
        avisos.append(f"{len(sitelinks)} sitelinks (o ideal é {IDEAL_SITELINKS})")
    textos, urls = {}, {}
    for s in sitelinks:
        texto = s.get("texto", "").strip()
        d1, d2 = s.get("descricao1", "").strip(), s.get("descricao2", "").strip()
        url = s.get("url", "").strip()
        if not texto or len(texto) > LIM_SITELINK:
            erros.append(f"sitelink com {len(texto)} caracteres no nome (de 1 a {LIM_SITELINK}): \"{texto}\"")
        if not d1 or not d2:
            erros.append(f"sitelink sem as 2 descrições (curta e longa): \"{texto}\"")
        for d in (d1, d2):
            if len(d) > LIM_SITELINK_DESC:
                erros.append(f"descrição de sitelink com {len(d)} caracteres (máx {LIM_SITELINK_DESC}): \"{d}\"")
        if not url.startswith("https://"):
            erros.append(f"sitelink \"{texto}\" com link que não começa com https:// (veio \"{url}\")")
        if normalizar(texto) in textos:
            erros.append(f"nome de sitelink repetido: \"{texto}\"")
        textos[normalizar(texto)] = True
        if url in urls:
            erros.append(f"link de sitelink repetido: \"{url}\" (use o hack do Matheus: a mesma página com #1, #2, #3...)")
        urls[url] = True

    frases = [f.strip() for f in r.get("frases", [])]
    if len(frases) < 4:
        erros.append(f"{len(frases)} frases de destaque (mínimo 4, o ideal é {IDEAL_FRASES})")
    elif len(frases) < IDEAL_FRASES:
        avisos.append(f"{len(frases)} frases de destaque (o ideal é {IDEAL_FRASES})")
    vistas = {}
    for f in frases:
        if len(f) > LIM_FRASE:
            erros.append(f"frase de destaque com {len(f)} caracteres (máx {LIM_FRASE}): \"{f}\"")
        if "!" in f:
            erros.append(f"frase de destaque com exclamação (o Google reprova): \"{f}\"")
        if normalizar(f) in vistas:
            erros.append(f"frase de destaque repetida: \"{f}\"")
        vistas[normalizar(f)] = True

    snippets = r.get("snippets", [])
    if not snippets:
        erros.append("nenhum snippet estruturado")
    elif len(snippets) < IDEAL_SNIPPETS:
        avisos.append(f"{len(snippets)} snippet (o ideal são {IDEAL_SNIPPETS} cabeçalhos diferentes)")
    for sn in snippets:
        cab = sn.get("cabecalho", "").strip()
        valores = [v.strip() for v in sn.get("valores", [])]
        if normalizar(cab) not in CABECALHOS:
            erros.append(f"cabeçalho de snippet que a API não aceita: \"{cab}\" (use Serviços ou Tipos; Bairros é recusado)")
        if not 3 <= len(valores) <= 10:
            erros.append(f"snippet \"{cab}\" com {len(valores)} valores (de 3 a 10)")
        elif len(valores) < 4:
            avisos.append(f"snippet \"{cab}\" com 3 valores (o ideal é 4 ou mais)")
        for v in valores:
            if len(v) > LIM_SNIPPET:
                erros.append(f"valor de snippet com {len(v)} caracteres (máx {LIM_SNIPPET}): \"{v}\"")

    if not r.get("telefone", "").strip():
        avisos.append("sem telefone: fica sem o recurso de ligação (ok se o negócio não atende ligação)")

    precos = r.get("precos", [])
    if precos:
        if not 3 <= len(precos) <= 8:
            erros.append(f"{len(precos)} itens de preço (de 3 a 8)")
        for p in precos:
            for campo in ("titulo", "descricao"):
                texto = p.get(campo, "").strip()
                if not texto or len(texto) > LIM_PRECO:
                    erros.append(f"preço com {campo} de {len(texto)} caracteres (de 1 a {LIM_PRECO}): \"{texto}\"")
            if not isinstance(p.get("valor"), (int, float)) or p.get("valor", 0) <= 0:
                erros.append(f"preço sem valor numérico: \"{p.get('titulo', '')}\"")
            if not p.get("url", "").startswith("https://"):
                erros.append(f"preço \"{p.get('titulo', '')}\" com link que não começa com https://")

    return erros, avisos


def main():
    if len(sys.argv) != 2:
        print(__doc__)
        sys.exit(2)
    with open(sys.argv[1], encoding="utf-8") as f:
        dados = json.load(f)

    total_erros = 0
    for g in dados.get("grupos", []):
        nome, erros, avisos = validar_grupo(g)
        status = "OK" if not erros else f"{len(erros)} ERRO(S)"
        print(f"\n== {g.get('campanha', '')} › {nome}: {status}")
        for e in erros:
            print(f"  ERRO  {e}")
        for a in avisos:
            print(f"  AVISO {a}")
        total_erros += len(erros)

    for r in dados.get("recursos", []):
        erros, avisos = validar_recursos(r)
        status = "OK" if not erros else f"{len(erros)} ERRO(S)"
        print(f"\n== Recursos · {r.get('campanha', '')}: {status}")
        for e in erros:
            print(f"  ERRO  {e}")
        for a in avisos:
            print(f"  AVISO {a}")
        total_erros += len(erros)

    print(f"\nResultado: {'aprovado' if total_erros == 0 else f'{total_erros} erro(s) pra corrigir'}")
    sys.exit(1 if total_erros else 0)


if __name__ == "__main__":
    main()
