# Checklist de conferência (etapa 7)

A conferência gasta **1 execução por campanha**: o `google_ads_check_campaign_serving` relê quase tudo numa chamada. O resto vem dos lotes da subida, que são tudo ou nada (se o lote passou, tudo nele foi gravado). Não faça consulta extra; se precisar de uma, diga quantas execuções gasta e pergunte antes. Se o check não trouxer um item (rede, presença, qual é o idioma, total de palavras), vale a resposta da gravação que criou aquilo: a rede vem na resposta da criação da campanha (`network_settings`) e o resto vem dos lotes, e lote que passou é lote gravado.

Preencha com OK ou PROBLEMA:

| # | Item | De onde vem | Esperado |
|---|---|---|---|
| 1 | Rede só Pesquisa | resposta da gravação 1 (`network_settings`) ou check | Google Search ligado; parceiros e Display desligados |
| 2 | Local por presença | check (presença e nº de locais) + gravação 2 (configurações) | PRESENCE e só a região do briefing, sem o país |
| 3 | Idioma | check | Português |
| 4 | Programação | gravação 2 (configurações) | 7 linhas, uma por dia (segunda a domingo), 00h às 24h, ou o horário de atendimento aprovado |
| 4b | Meta de conversão | 5ª gravação, se houve | Só as metas de contato escolhidas (WhatsApp, ligação, formulário), não o padrão da conta |
| 5 | Lance escrito | check | A estratégia escolhida na 1ª aprovação (fim da etapa 3): Maximizar cliques (`TARGET_SPEND`) ou Maximizar conversões, nunca o CPC manual por acaso |
| 6 | Verba certa | check | O diário aprovado (o teto do mês é diário × 30,4, e o Google pode gastar até 2x num dia) |
| 7 | Palavras e negativas | check (contagem) | As quantidades aprovadas |
| 8 | Anúncio completo | gravação 3 (estrutura) + revisão no check | 1 RSA por grupo, 15 títulos (o último `[Recomendado]`), 4 descrições, link certo, nenhum título fixado; "em revisão" é normal no começo |
| 9 | Recursos | gravação 4 (recursos) | O que estava no plano final: 6 sitelinks (com as 2 descrições e links `#1`, `#2`...), 8 frases e os snippets; ligação e preço só se entraram no plano. Tudo ligado à campanha |
| 10 | Status | check | Campanha, grupos e anúncios pausados. As palavras ficam ativas dentro do grupo pausado: é o esperado, não é problema |
| 11 | Apta a rodar | check | Sem bloqueio além de "pausada". Se aparecer pagamento ou conta suspensa, avise que se resolve no Google Ads, em Faturamento |

**Pro usuário conferir no Google Ads** (sem gastar execução; vai no resumo final):
- nome da empresa, logo e fotos do produto ou serviço: a skill não coloca (dependem do negócio); confira e adicione na campanha;
- pagamento em dia (Faturamento);
- conversão funcionando (WhatsApp, ligação ou formulário): sem ela, o Google não aprende e a otimização fica no escuro;
- campanhas antigas que vendem o mesmo serviço: pausar, pra não disputarem as mesmas buscas;
- aprovação do anúncio no dia seguinte.

Termine pedindo ao usuário pra abrir o Google Ads e conferir junto. **Ativar só com pedido explícito** ("pode ativar a campanha X").
