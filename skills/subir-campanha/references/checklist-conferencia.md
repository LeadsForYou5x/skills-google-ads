# Checklist de conferência (etapa 7)

A conferência gasta **1 execução por campanha**: o `google_ads_check_campaign_serving` relê quase tudo numa chamada. O resto vem dos lotes da subida, que são tudo ou nada (se o lote passou, tudo nele foi gravado). Não faça consulta extra; se precisar de uma, diga quantas execuções gasta e pergunte antes.

Preencha com OK ou PROBLEMA:

| # | Item | De onde vem | Esperado |
|---|---|---|---|
| 1 | Rede só Pesquisa | check | Google Search ligado; parceiros e Display desligados |
| 2 | Local por presença | check (presença e nº de locais) + lote do passo 2 | PRESENCE e só a região do briefing, sem o país |
| 3 | Idioma | check | Português |
| 4 | Programação | lote do passo 2 | 7 linhas, uma por dia (segunda a domingo), 00h às 24h, ou o horário de atendimento aprovado |
| 4b | Meta de conversão | 5ª gravação, se houve | Só as metas de contato escolhidas (WhatsApp, ligação, formulário), não o padrão da conta |
| 5 | Lance escrito | check | A estratégia aprovada na etapa 4: Maximizar cliques (`TARGET_SPEND`) ou Maximizar conversões, nunca o CPC manual por acaso |
| 6 | Verba certa | check | O diário aprovado (o teto do mês é diário × 30,4, e o Google pode gastar até 2x num dia) |
| 7 | Palavras e negativas | check (contagem) | As quantidades aprovadas |
| 8 | Anúncio completo | lote do passo 3 + revisão no check | 1 RSA por grupo, 15 títulos (o último `[Recomendado]`), 4 descrições, link certo, nenhum título fixado; "em revisão" é normal no começo |
| 9 | Recursos | lote do passo 4 | 6 sitelinks (com as 2 descrições e links `#1`, `#2`...), 8 frases, 2 snippets, ligação e preço, ligados à campanha |
| 10 | Status | check | Tudo pausado |
| 11 | Apta a rodar | check | Sem bloqueio além de "pausada". Se aparecer pagamento ou conta suspensa, avise que se resolve no Google Ads, em Faturamento |

**Pro usuário conferir no Google Ads** (sem gastar execução; vai no resumo final):
- nome da empresa, logo e fotos do produto ou serviço: a skill não coloca (dependem do negócio); confira e adicione na campanha;
- pagamento em dia (Faturamento);
- conversão funcionando (WhatsApp, ligação ou formulário): sem ela, o Google não aprende e a otimização fica no escuro;
- campanhas antigas que vendem o mesmo serviço: pausar, pra não disputarem as mesmas buscas;
- aprovação do anúncio no dia seguinte.

Termine pedindo ao usuário pra abrir o Google Ads e conferir junto. **Ativar só com pedido explícito** ("pode ativar a campanha X").
