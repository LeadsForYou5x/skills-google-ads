---
name: revisar-lances
description: "Revisa lances e estratégia de lance de campanhas de Pesquisa do Google Ads no método do Matheus Zappiello: se a estratégia combina com o volume de conversões, quanto se perde por orçamento ou por classificação, e ajustes de lance por localização, horário, dispositivo e público. Só propõe; grava apenas o que o usuário aprovar. Use quando o usuário pedir revisão de lance, estratégia de lance, CPA alvo, maximizar conversões, parcela de impressões, ajuste por horário/local/dispositivo, ou digitar /revisar-lances."
---

# Revisar lances

No método do Matheus, o lance é a outra metade da posição (junto com a qualidade), e uma das otimizações é **ajustar lance por localização, horário, palavra, dispositivo e público**. Explique em uma frase no começo.

## Como esta skill trabalha
- **Onde ficam os arquivos:** em `google-ads/<negocio>/`, dentro da pasta aberta nesta conversa (numa tarefa agendada, a pasta em que ela foi criada). Leia o `negocio.md` (o que vende, região, objetivo, ticket, conta) e o `alteracoes.md` (o que já mudou na conta e o que o usuário recusou), se existirem, e não pergunte de novo o que já está lá. Se o `negocio.md` já tem a conta, use ela direto, sem listar as contas de novo. Se o usuário não disse o negócio e houver mais de um salvo, pergunte no popup qual é (até 4 nomes; se houver mais, os mexidos por último). Pasta nova: nome em minúsculas, sem acento e com hífen (ex.: `climatiza-campinas`). Não abra pastas de outros negócios nem comente clientes, contas ou projetos que ele não citou.
- **Mudança recente:** se o `alteracoes.md` mostra uma mudança de menos de 7 dias no assunto desta revisão, avise logo no começo que os números de 30 dias ainda são, quase todos, de antes dela. Separe o que **já foi resolvido** do que **continua acontecendo** e não proponha de novo o que já foi feito nem o que foi recusado.
- **Negócio sem `negocio.md`** (conta que não foi criada pela `/subir-campanha`): pergunte no chat, numa mensagem só, o nome do negócio e o que ele vende. Liste as contas (`google_ads_list_customers`, 1 execução) e pergunte num popup só: qual é a conta (uma opção por conta, com nome e ID, só as que vêm com `can_query_metrics` verdadeiro, porque as outras são contas de gerente; com 1 conta só, não pergunte: use ela e diga o nome no chat; com mais de 4, mostre as 4 de nome mais parecido com o negócio, e as outras vão no "Outro"), o que conta como resultado (WhatsApp, ligação, formulário, venda; `multiSelect`), quanto vale um cliente (em faixas) e em que dias atende. Salve o `negocio.md` na hora, pra próxima revisão não perguntar de novo. Numa tarefa agendada, não pergunte: use a conta do pedido, siga sem o perfil e anote no relatório o que faltou.
- **Tarefa agendada** (o pedido já diz o negócio e a conta e manda não alterar nada): não pergunte nada. Decida pelo padrão, anote as dúvidas no relatório, salve e pare, sem aplicar nada. Termine com 3 linhas: o achado mais importante, onde está o relatório e como aplicar ("abra uma conversa nesta pasta e peça: aplica o relatório de lances de DD/MM").
- **Na conversa:** toda decisão vai no popup (ferramenta `AskUserQuestion`: opções pra clicar e o campo "Outro"). Se ele não existir, pergunte no chat.
- **Aplicar um relatório já salvo:** se o usuário pedir pra aplicar um relatório (ex.: "aplica o relatório de lances de hoje"), não refaça a análise. Leia o mais recente desse tipo em `revisoes/`, mostre as propostas dele e vá pro passo 6 (Aplicar). Se ele tiver mais de 7 dias, avise e pergunte no popup se refaz antes.
- **Execuções do Pipeboard:** com pouco dado, 1; revisão completa, de 3 a 7; aplicar, 1 por mudança. Rode ao mesmo tempo as leituras que não dependem uma da outra. Se o Google recusar uma consulta, corrija uma vez (o erro diz o campo); se falhar de novo, pule esse item, marque "não conferido" no relatório e siga. Antes de gastar mais que o previsto, pergunte (na agendada, não gaste: anote no relatório o que ficou sem conferir, termine e salve).
- **Como falar:** mostre o resultado, não o processo (nada de contar consulta, ferramenta ou arquivo). Frase simples, tabelas, números em destaque e nenhum termo técnico sem explicação.

## Como explicar cada proposta
Quem lê pode ser iniciante e precisa entender **o que vai ser feito e por quê** antes de aprovar. Toda proposta, no relatório, no chat e no popup, responde 4 coisas:

| | Exemplo |
|---|---|
| **O que fazer** (a ação exata e onde) | Subir a verba de R$ 30 pra R$ 40 por dia |
| **Por quê** (o número, comparado com a referência) | A campanha perdeu 35% das buscas por falta de verba, e cada contato custa R$ 12, abaixo dos R$ 20 de referência |
| **O que muda na conta** (e se dá pra desfazer) | Só o valor por dia muda (o teto do mês vai de R$ 912 pra R$ 1.216). Dá pra voltar quando quiser |
| **Resultado esperado** (sem prometer) | Uns 20 contatos a mais por mês, se o custo por contato se mantiver |

O popup pode cobrir o chat, então ele tem que se explicar sozinho:
- a pergunta diz o negócio e o que está sendo decidido, com o número principal;
- cada opção tem nome de ação (ex.: "Subir a verba pra R$ 40 por dia"), nunca nome de skill nem termo técnico, e a descrição diz o porquê e o que muda;
- a recomendada vem primeiro, com "(Recomendado)" no fim, em português;
- de 2 a 4 opções por pergunta, até 4 perguntas por popup e título de até 12 caracteres; o "Outro" o app já põe.

Se a revisão não achar nada que valha mexer, diga isso em 1 linha, com o número que mostra que está tudo certo, e **não abra o popup de aplicar**. "Não mexer agora" também é proposta: diga o porquê (pouco dado, mudança recente, custo igual nos dois caminhos).

## Pouco dado: o caminho curto
Comece sempre pela consulta da seção 2 (1 execução, todas as campanhas de Pesquisa de uma vez). A campanha com **menos de 100 cliques nos 30 dias** (o normal no primeiro mês de uma campanha criada pela `/subir-campanha`) segue o caminho curto: é cedo pra mexer em lance, então pule as seções 1, 3 e 4. A que tem 100 cliques ou mais segue a revisão completa, mesmo sendo nova.

No caminho curto, responda em linguagem simples, com os números que já tem:
- **O Google está aprendendo ou travado?** `bidding_strategy_system_status` começando com `LEARNING` = aprendendo (não mexa, espere); `LIMITED_BY_BUDGET` = falta verba; `LIMITED_BY_DATA` = poucas conversões; `MISCONFIGURED...` = configuração errada (diga qual). `primary_status_reasons` diz por que a campanha não roda bem (verba, anúncio reprovado, palavra sem busca).
- **Faltou verba?** Perdida por orçamento acima de 20%, com contato a um custo bom → a verba limita: sugira subir ou concentrar nos grupos que mais trazem contato.
- **O lance ficou alto ou baixo?** Compare o CPC médio com a faixa de topo do Planejador (o `03-volume.md` da campanha). Bem acima e pouco contato → sugira um **CPC máximo** perto da faixa de topo. Perdida por classificação acima de 30% → lance baixo ou qualidade fraca (cruze com `/revisar-palavras`).
- **Quanto custou cada contato?** Gasto ÷ conversões, se estiver medindo. Compare com o ticket do `negocio.md`.
- **Já dá pra Maximizar conversões?** Só com 15 conversões ou mais nos 30 dias, e **sem** custo por contato desejado no começo (tabela da seção 2). O custo desejado só entra com mais de 30 conversões, tirado do simulador (seção 2), nunca do custo médio.

Entregue no formato da seção 5 (resumo e "o que eu faria primeiro", com as 4 respostas), diga o que falta pra dar pra mexer e salve em `google-ads/<negocio>/revisoes/lances-AAAA-MM-DD.md`. Só vá pra seção 6 (Aplicar) se houver o que aplicar.

## 1. Na revisão completa, antes de propor: dá pra mexer?
Leia antes o `alteracoes.md` (não gasta execução). Depois consulte o histórico dos últimos 14 dias, que pega também o que foi mudado direto no Google Ads (o `change_event` só aceita até 30 dias e exige `LIMIT`):
```sql
SELECT change_event.change_date_time, change_event.change_resource_type, change_event.resource_change_operation,
       change_event.changed_fields, change_event.client_type, change_event.user_email, campaign.name
FROM change_event
WHERE change_event.change_date_time DURING LAST_14_DAYS
ORDER BY change_event.change_date_time DESC
LIMIT 200
```
Se o lance ou a verba da campanha mudou há **menos de 7 dias**, avise que o algoritmo ainda está aprendendo e recomende esperar. Só siga com essa campanha se o usuário quiser (numa tarefa agendada, anote no relatório, não proponha mudança de lance nem de verba pra ela e siga com as outras campanhas).

`client_type` diz por onde veio a mudança. `GOOGLE_ADS_RECOMMENDATIONS_SUBSCRIPTION` quer dizer que o Google aplicou uma recomendação sozinho: avise o usuário e sugira desligar em Recomendações › Aplicar automaticamente. Não mostre o e-mail de quem mexeu: diga só se foi uma pessoa, uma ferramenta ou o próprio Google.

## 2. Estratégia certa pro volume de conversões
```sql
SELECT campaign.id, campaign.name, campaign.bidding_strategy_type, campaign.bidding_strategy_system_status,
       campaign.primary_status, campaign.primary_status_reasons,
       campaign.maximize_conversions.target_cpa_micros, campaign.target_spend.cpc_bid_ceiling_micros,
       campaign_budget.amount_micros, metrics.conversions, metrics.cost_micros, metrics.clicks, metrics.average_cpc,
       metrics.search_impression_share, metrics.search_budget_lost_impression_share,
       metrics.search_rank_lost_impression_share, metrics.search_top_impression_share
FROM campaign
WHERE segments.date DURING LAST_30_DAYS AND campaign.advertising_channel_type = 'SEARCH' AND campaign.status = 'ENABLED'
```
| Conversões nos últimos 30 dias | Estratégia recomendada |
|---|---|
| Menos de 15 | Maximizar cliques (com teto de CPC se o clique estiver caro) |
| 15 a 30 | Maximizar conversões (sem CPA alvo) |
| Mais de 30, estável | Maximizar conversões com **CPA alvo** |

A tabela serve pra escolher e pra subir de estratégia. Campanha que já está em Maximizar conversões com custo por contato bom fica como está, mesmo com menos de 15 conversões: não proponha voltar pra Maximizar cliques. Acima de 30, o CPA alvo é opcional.

**O simulador do Google** (1 execução) diz o que ele prevê pra cada campanha, por semana. Nunca proponha CPA alvo nem verba pela média: use os pontos dele.
```sql
SELECT campaign_simulation.campaign_id, campaign_simulation.type, campaign_simulation.start_date,
       campaign_simulation.end_date, campaign_simulation.budget_point_list.points,
       campaign_simulation.target_cpa_point_list.points
FROM campaign_simulation
WHERE campaign_simulation.type IN ('BUDGET', 'TARGET_CPA')
```
- **`TARGET_CPA` (CPA alvo):** cada ponto traz o CPA alvo e o custo, cliques e conversões previstos. Ache o alvo cujo custo previsto bate com o gasto real de uma semana (o gasto de 30 dias ÷ 30 × 7, sem consulta extra) e comece por ele. Depois, desça **no máximo 10 a 15% a cada 2 semanas**. Alvo baixo demais pode zerar a entrega.
- **`BUDGET` (verba):** cada ponto traz uma verba por dia (`budgetAmountMicros`) e o custo e as conversões previstos com ela (`costMicros`, `biddableConversions`). Cada contato a mais custa (custo do ponto maior − custo do ponto de hoje) ÷ (conversões do ponto maior − conversões do ponto de hoje). Entre várias campanhas, verba nova vai primeiro pra campanha em que o contato extra sai mais barato. Os pontos pulam de valor (ex.: R$ 20 e depois R$ 64): pra uma verba no meio, faça a conta proporcional e diga que é estimativa.
- Tipo sem nenhum ponto: a campanha ainda não tem dado pra esse simulador. Fique na estratégia atual e não invente previsão.

Sem conversão medindo, nenhuma estratégia "por conversão" funciona: aponte isso como prioridade 1.

**Lance automático aprendendo ou limitado?** O campo `campaign.bidding_strategy_system_status` da consulta acima diz: começando com `LEARNING` = aprendendo (não mexa, espere); `LIMITED_BY_BUDGET` = falta verba; `LIMITED_BY_DATA` = poucas conversões; `LIMITED_BY_CPC_BID_CEILING` = o CPC máximo está baixo; `MISCONFIGURED...` = configuração errada. Não gaste execução com `google_ads_get_bidding_strategy_report`: ele só lista estratégias de portfólio.

## 3. Parcela de impressões perdida
Já vem na consulta da seção 2 (parcela de impressões, perdida por verba, perdida por classificação e % no topo), sem gastar outra execução. O nome dos concorrentes não vem pelo conector: só aparece no site do Google Ads (Insights › Leilão).
- **Perdida por orçamento** alta (> 20%) e custo por resultado bom → sugerir aumentar a verba ou concentrar nos grupos que mais vendem. Mostre o número do simulador de verba (seção 2): quantos contatos a mais e quanto custa cada um.
- **Perdida por classificação** alta (> 30%) → o problema é lance ou qualidade: cruzar com `/revisar-palavras` (índice de qualidade) antes de subir lance.

## 4. Ajustes por dia, aparelho e cidade (lista do método)
Só com dado suficiente (100 cliques ou mais na campanha em 30 dias). Cada leitura gasta 1 execução: faça só as que fazem sentido pro negócio, no máximo 4 desta seção (com as 3 de antes, a revisão fecha em 7). Ordem: dia da semana, aparelho, cidade (2 leituras, se atende mais de uma) e, só se couber, hora e público.
- **Dia da semana, aparelho e hora** (1 execução cada, todas as campanhas de uma vez):
  ```sql
  SELECT campaign.id, campaign.name, segments.day_of_week, metrics.clicks, metrics.cost_micros, metrics.conversions
  FROM campaign
  WHERE segments.date DURING LAST_30_DAYS AND campaign.advertising_channel_type = 'SEARCH' AND campaign.status = 'ENABLED'
  ```
  Pra aparelho, troque `segments.day_of_week` por `segments.device`; pra hora, por `segments.hour` (só se o negócio quer cortar um horário, ex.: madrugada sem atendimento). Comece pelo dia da semana.
- **Dia ou horário em que o negócio não atende** (pelo `negocio.md`; se não estiver lá, pergunte no popup junto com o OK) e que custa mais por resultado: proponha **tirar**. Campanha sem programação nenhuma: é criar as linhas só dos dias que ficam (formato na seção 6). Campanha que já tem 1 linha por dia: é remover a linha do dia.
- **Cidade:** só se a campanha atende mais de uma cidade. A ferramenta `google_ads_get_geo_performance` traz por país; por cidade, use (1 execução, todas as campanhas):
  ```sql
  SELECT campaign.id, campaign.name, campaign.status, segments.geo_target_city, metrics.clicks, metrics.cost_micros, metrics.conversions
  FROM geographic_view
  WHERE segments.date DURING LAST_30_DAYS AND campaign.status = 'ENABLED'
  ```
  O resultado traz o código de cada cidade; os nomes saem de `geo_target_constant` (mais 1 execução).
- **Público:** `google_ads_get_audiences` com `audience_type: "REMARKETING"` lista as listas de remarketing que **existem na conta** (quem já visitou o site); ele não diz se a lista já está na campanha nem como rende. Se houver lista, ofereça colocar em **observação**, sem restringir quem vê o anúncio: `google_ads_add_audience_to_campaign` com `audience_id` (o `id` da lista) e `audience_type: "USER_LIST"` (se ela já estiver na campanha, o Google recusa a repetida: é só seguir). Depois de 30 dias dá pra dar lance maior pra quem já conhece a empresa: é um `update` do critério com `bidModifier` (ex.: `1.2`), no formato dos ajustes da seção 6, só com Maximizar cliques ou CPC manual. Público personalizado não vale pra Pesquisa.

Regra de proposta: compare o custo por resultado de cada segmento com o da campanha.
- 30% mais barato e com volume relevante → ajuste **+10% a +20%**.
- 50% mais caro ou gasto > 3x o custo de referência sem resultado → ajuste **-20% a -50%**, ou excluir (local/horário em que o negócio não atende).
- Pouco dado (menos de 100 cliques no segmento, ou campanha com menos de 10 conversões nos 30 dias) → não mexer: com menos que isso, a diferença de custo é acaso.
Com Maximizar conversões ou CPA alvo, o Google **não usa** ajuste de lance por dia, hora, local nem público (só vale tirar um aparelho com -100%; no CPA alvo, o ajuste de aparelho muda o alvo, não o lance). Nesses casos não proponha ajuste: proponha **excluir** o dia, o horário ou o local que não serve. Os ajustes desta seção valem com Maximizar cliques e com CPC manual.

## 5. Entregar
1. **Resumo em 3 linhas:** quanto gastou, quantos contatos vieram e quanto custou cada um; se a campanha está limitada (por verba, por lance ou porque o Google ainda está aprendendo).
2. **O que eu faria primeiro:** até 3 propostas, cada uma com as 4 respostas (o que fazer, por quê, o que muda na conta, resultado esperado). Uma mudança de lance por campanha de cada vez: se houver mais de uma boa ideia, diga a ordem e o intervalo (7 a 14 dias entre elas).
3. **Tabela por campanha:** estratégia hoje · contatos em 30 dias · perdeu por verba · perdeu por lance · recomendação.
4. **Ajustes por dia, aparelho ou cidade** (se houver dado): onde · custo por contato · comparado com a campanha · ajuste proposto.

Salve em `google-ads/<negocio>/revisoes/lances-AAAA-MM-DD.md`. No fim do arquivo, ponha o bloco **Dados pra aplicar** (é pro Claude, não pro leitor): ID da conta e, pra cada item proposto, o ID da campanha, a verba e a estratégia de hoje e o valor proposto. Numa tarefa agendada, pare aqui.

## 6. Aplicar (só com OK)
Pergunte no popup, com a pergunta completa (ex.: "Climatiza: subo a verba de R$ 30 pra R$ 40 por dia? A campanha perdeu 35% das buscas por falta de verba."). As opções têm nome de ação e a descrição diz o que muda:
- **<a ação recomendada> (Recomendado)** (ex.: "Subir a verba pra R$ 40 por dia")
- **<a segunda opção, se houver>** (ex.: "Manter a verba e pôr um CPC máximo de R$ 3")
- **Nada agora**: "Fica salvo no relatório; dá pra aplicar depois."

Ao gravar (diga antes, em 1 linha, o que vai gravar e quantas execuções gasta):
- Verba: `google_ads_update_campaign` com `budget_amount_micros` (R$ 40 = `40000000`).
- Estratégia: `google_ads_update_campaign` com `bidding_strategy_type` (`TARGET_SPEND` = Maximizar cliques; `MAXIMIZE_CONVERSIONS`; com custo por contato desejado, `TARGET_CPA` e `target_cpa_micros`).
- CPC máximo no Maximizar cliques: `google_ads_execute_mutate` com `resource_type: "campaigns"`, `update` com `targetSpend.cpcBidCeilingMicros` e `updateMask: "target_spend.cpc_bid_ceiling_micros"`. Esse formato ainda não foi testado numa conta: se o Google recusar, diga pra ajustar no Google Ads (Campanha › Configurações › Lances).
- Ajustes por dia, aparelho ou cidade: `google_ads_execute_mutate` com `resource_type: "campaignCriteria"`, `update` no critério com `bidModifier` (ex.: `1.2` = +20%, `0.8` = -20%) e `updateMask: "bid_modifier"`. O nome do critério é `customers/<conta>/campaignCriteria/<id da campanha>~<id do critério>`. Pra achar os IDs (1 execução):
  ```sql
  SELECT campaign.id, campaign_criterion.criterion_id, campaign_criterion.type, campaign_criterion.negative,
         campaign_criterion.ad_schedule.day_of_week, campaign_criterion.location.geo_target_constant,
         campaign_criterion.device.type, campaign_criterion.bid_modifier
  FROM campaign_criterion
  WHERE campaign.id = <id da campanha> AND campaign_criterion.type IN ('AD_SCHEDULE', 'LOCATION', 'DEVICE')
  ```
  Aparelho já existe em toda campanha, com IDs fixos: computador `30000`, celular `30001`, tablet `30002`. Pra tirar um local que está incluído na campanha (linha `LOCATION` com `negative` falso), **remova** a linha dele: `[{"remove": "customers/<conta>/campaignCriteria/<id da campanha>~<id do critério>"}]`. Criar o mesmo local como negativo bate no critério que já existe e o Google recusa. Só crie com `negative: true` a cidade que fica dentro de uma área maior que a campanha mira (estado ou raio) e não é, ela mesma, um local da campanha. Pra tirar um dia, remova a linha dele. Campanha sem programação: crie 1 linha por dia que fica, todas num lote só (`create` com `campaign` e `adSchedule`: `dayOfWeek`, `startHour: 0`, `startMinute: "ZERO"`, `endHour: 24`, `endMinute: "ZERO"`).

## Pra fechar (na conversa)
1. Se algo foi gravado, mostre numa tabela **Antes → Depois** só o que mudou de verdade (a resposta do conector confirma; não gaste execução relendo).
2. Anote em `google-ads/<negocio>/alteracoes.md` (crie se não existir), uma linha por mudança: data · o que mudou · por quê · quando olhar de novo. O que o usuário recusou também entra ("manter X: motivo"), pra não ser proposto de novo. O que ficou em "Nada agora" entra à parte, como **em aberto** (data e relatório): não é recusa. Na próxima revisão, lembre em 1 linha e só pergunte de novo se o número mudou.
3. Diga em 1 linha o que observar e quando (ex.: "espere de 7 a 14 dias antes de mexer de novo; o Google precisa desse tempo pra se ajustar").
4. **Calendário:** se o `negocio.md` não fala do calendário (agendado ou recusado), ofereça deixar as revisões agendadas: abra a skill `agendar-otimizacao` (ferramenta Skill) e siga ela, com o negócio e a conta desta conversa. Se ela não estiver instalada, diga que dá pra agendar pedindo "todo dia 20 às 9h, use a skill revisar-lances no negócio <negócio> (conta <ID>), salve o relatório e não altere nada na conta".

## Segurança
Só grava com o OK do usuário no popup; numa tarefa agendada, nunca grava. Uma mudança de lance por vez em cada campanha. Nunca troque estratégia e verba no mesmo dia.
