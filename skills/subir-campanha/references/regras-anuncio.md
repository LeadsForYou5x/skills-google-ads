# Regras do anúncio (RSA) no método

## Obrigatório em todo grupo
- **15 títulos diferentes**, cada um com **até 30 caracteres** (espaço conta).
- **4 descrições diferentes**, cada uma com **até 90 caracteres**.
- **Link final** da página certa pro grupo (se houver página específica do serviço, use ela).
- **2 caminhos** (path1/path2) de até 15 caracteres, sem acento, com a palavra do grupo (ex.: `instalacao` / `campinas`).

## Como distribuir os 15 títulos (como o Matheus faz)
**5 do produto/serviço + 5 diferenciais + 4 CTA + `[Recomendado]` no 15º.**

| Bloco | Quantos | Exemplos (grupo "instalação de ar condicionado") |
|---|---|---|
| Produto/serviço (o que é, com a palavra do grupo) | 5 | Instalação De Ar Condicionado · Instalação De Ar Em Campinas |
| Diferenciais / vantagens | 5 | Técnicos Certificados · Garantia De 1 Ano Na Instalação |
| CTA (chamada pra ação) | 4 | Orçamento Pelo WhatsApp · Agende Sua Visita Hoje |
| Fecho fixo | 1 | **[Recomendado]**, sempre o 15º, o último da lista |

- **O 15º título é sempre o texto `[Recomendado]`**, exatamente assim, com os colchetes. É como o Matheus faz: os 14 primeiros são escritos pro grupo e o último fecha a lista. Na conferência do dia seguinte, veja se o anúncio foi aprovado.
- Pelo menos 2 títulos com a palavra-chave do grupo, quase igual à busca. Se a palavra for longa (ex.: "instalação de ar condicionado", 29 caracteres), ela só cabe uma vez: use uma variação curta no segundo ("Instalação De Ar Em Campinas") e deixe o aviso do validador explicado.
- Não repetir a mesma ideia com palavras diferentes: o Google precisa de peças diferentes pra combinar.
- Números e provas concretas valem mais que adjetivo ("15 Anos De Experiência" > "Melhor Empresa").

## Escrita
- **Maiúscula No Início De Cada Palavra** em todos os títulos (inclusive "De", "Do", "Em", como nos exemplos do curso).
- Descrições em frase normal, com ponto final e uma chamada pra ação.
- Sem exclamação no título (o Google reprova), sem CAIXA ALTA inteira, sem emoji.
- Nada de promessa que o negócio não cumpre ou que o site não mostra.

## Fixação (pin)
- **Nunca fixe título.** Os 15 vão soltos e o Google combina: fixar derruba a força do anúncio e limita as combinações.

## Recursos da campanha (configuração completa, o máximo que der)
Anúncio com configuração completa é fator de qualidade no método. Sempre preencha tudo isto:

| Recurso | Quantos | Regras |
|---|---|---|
| **Sitelinks** | **6** (mínimo 4) | Nome até 25 caracteres + **descrição curta** e **descrição longa** (as duas linhas, até 35 cada; sem elas o sitelink aparece pequeno) + link |
| **Frases de destaque** | **8** (mínimo 4) | Até 25 caracteres cada, sem exclamação. Diferenciais e provas: "Garantia De 1 Ano", "Atendimento Em 24h" |
| **Snippets estruturados** | **2 cabeçalhos** (mínimo 1) | Cabeçalho **Serviços** ou **Tipos** (os testados na API; "Bairros", mesmo na lista do Google, é recusado) e de 4 a 10 valores de até 25 caracteres. Ex.: "Serviços": Instalação, Limpeza, Manutenção, Conserto · "Tipos": Split, Janela, Cassete, Piso-teto |
| **Ligação** | 1 | Telefone do negócio, se ele atende por telefone |
| **Preço** | 3 a 8 itens (opcional) | Só se o negócio aceita mostrar preço. Cada item: título e descrição até 25 caracteres, valor "a partir de" e link |
| **Nome da empresa, logo e fotos** | não entram | A skill não coloca: dependem do negócio e mudam muito. No plano final e no resumo, avise o usuário pra conferir e adicionar no Google Ads |

**O hack do Matheus nos sitelinks:** o link de cada sitelink é a **página de destino da campanha com `#1`, `#2`, `#3`...** no fim (ex.: `https://climatiza.com.br/instalacao#1`, `.../instalacao#2`). Assim cada sitelink tem um link diferente, como o Google exige, mas todos levam pra página que converte. Se o site tiver páginas próprias que fazem sentido (ex.: página de avaliações), pode usar a página própria; senão, use o hack.

## Validação obrigatória
Antes de mostrar os anúncios pro usuário aprovar, rode o validador (`scripts/validar_anuncio.py`; num Mac sem Python, o `.js` com o `osascript`; num Windows sem Python, o `.ps1` com o PowerShell; veja o SKILL.md). Só apresente quando passar sem erro.
