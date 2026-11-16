# Conector do Google Ads: ferramentas e armadilhas

A skill foi escrita e testada com o **Pipeboard** (`https://google-ads.mcp.pipeboard.co/`). Com outro conector, use a ferramenta equivalente; os nomes abaixo são os do Pipeboard.

## Tudo que o Pipeboard faz no Google Ads (e onde o pacote usa)
| Pra quê | Ferramentas | Onde entra |
|---|---|---|
| **Planejar palavras** | `google_ads_get_keyword_ideas` (ideias novas) · `google_ads_get_keyword_historical_metrics` (volume e lance de uma lista) · `google_ads_get_keyword_forecast` (previsão de cliques, custo e CPC pra uma verba e lance) | subir-campanha, etapas 3 e 4 |
| **Ler a conta** | `google_ads_list_customers` · `google_ads_get_account_info` · `google_ads_get_campaigns` · `_get_ad_groups` · `_get_ads` · `_get_keywords` · `_get_negative_keywords` · `_get_shared_negative_keyword_lists` · `_get_extensions` · `google_ads_list_assets` · `_get_audiences` · `google_ads_execute_gaql_query` (qualquer consulta) | todas |
| **Relatórios** | `google_ads_get_campaign_metrics` · `_get_ad_group_metrics` · `_get_ad_metrics` · `_get_keyword_metrics` · `_get_search_terms_report` · `_get_geo_performance` · `_get_device_performance` · `_get_hour_of_day_performance` · `_get_bidding_strategy_report` · `_get_auction_insights` (só a **sua** parcela e posição; o nome dos concorrentes só aparece no site do Google Ads) | revisões e auditoria |
| **Diagnóstico** | `google_ads_check_campaign_serving` (por que roda ou não roda, numa chamada) | subir-campanha etapa 7, auditoria |
| **Criar** | `google_ads_create_campaign` · `_create_ad_group` · `_add_keywords` · `_add_negative_keywords` · `_create_responsive_search_ad` · `_set_geo_targeting` (cidade pelo nome ou **raio em km a partir de um endereço**) · `_set_language_targeting` · `_update_network_settings` · `_create_sitelink` · `_create_callout` · `_create_structured_snippet` · `_create_call_extension` · `google_ads_upload_asset` (imagem a partir de um **link público** da foto) · `_add_audience_to_campaign` (lista de remarketing em observação) | subir-campanha |
| **Editar** | `google_ads_update_campaign` · `_update_ad_group` · `_update_keyword_bid` · `_pause_` e `_enable_` (campanha, anúncio, palavra) · `_remove_keywords` · `_remove_negative_keywords` · `_update_extension_status` · `_remove_extension` | revisões |
| **Qualquer outra coisa** | `google_ads_execute_mutate`: lote com tudo de uma vez, editar anúncio no lugar, ajuste de lance por dia/local/aparelho, lista de negativas compartilhada, preço, imagem na campanha | subir-campanha, revisões |
| **Conversão do CRM** | `google_ads_upload_click_conversions` · `_upload_conversion_adjustments` (venda fechada volta pro Google pelo código do clique, o GCLID) | auditoria (sugestão avançada) |
| **Plano do Pipeboard** | `manage_account_slots` (ver e trocar as vagas de conta) | quando der erro de vaga |

Fora do pacote (o Pipeboard faz, mas não é campanha de Pesquisa): Performance Max, Shopping, Display, Vídeo, Demand Gen, faturas (`list_invoices`, `download_invoice_pdf`), convite de MCC (`send_invitation`) e as outras plataformas (Meta, Microsoft, TikTok...).

**Ferramenta pronta ou lote?** Cada chamada gasta 1 execução. As ferramentas prontas criam um item por vez; o `google_ads_execute_mutate` em lote cria tudo numa chamada só. Pra criar, prefira o lote (abaixo). Pra ler e pra editar uma coisa só, prefira a ferramenta pronta.

## Armadilhas (leia antes de subir)
1. **Campo que você não manda vira o padrão do Google, sem erro.** Sempre informe a estratégia de lance (`bidding_strategy_type`) e o orçamento na criação, e **releia a campanha depois** pra conferir. Maximizar cliques é `TARGET_SPEND`; sem informar, o conector cria em CPC manual.
2. **A campanha nasce mirando o país inteiro** (o conector põe o Brasil, `2076`, sozinho). **Adicionar a cidade não basta**: o Brasil continua lá e a campanha segue mirando o país todo. Remova o critério `customers/<conta>/campaignCriteria/<campanha>~2076` no mesmo lote em que põe a cidade (testado em 02/11/26).
3. **Local por presença:** o padrão do Google é "presença ou interesse". Pra atender só quem está na região, atualize a campanha com `google_ads_execute_mutate`: recurso `campaigns`, `update` com `geo_target_type_setting.positive_geo_target_type = "PRESENCE"` e `updateMask: "geo_target_type_setting.positive_geo_target_type"`. Na conferência, o `google_ads_check_campaign_serving` mostra a presença.
4. **Idioma:** português é `1014` (`google_ads_set_language_targeting`).
5. **Rede:** pra Pesquisa, Display e parceiros desligados (o Pipeboard já cria assim; confira na releitura).
6. **Dinheiro em micros:** R$ 50 = `50000000`. R$ 2,50 de CPC = `2500000`.
7. **Tudo nasce pausado** (campanha, grupo, anúncio). Nunca ative sem pedido explícito do usuário.
8. **Planejador:** conta sem gasto recente recebe faixa de volume em vez de número exato. Avise o usuário quando for o caso.
9. **Limite do plano grátis do Pipeboard:** 30 execuções por semana e 2 contas por mês. Cada chamada conta. Com a subida em lote (abaixo), uma campanha completa sobe em **4 execuções**; o fluxo todo, com volume, previsão e conferência, fica em umas 11 (tabela no SKILL.md). Antes de subir, diga ao usuário quantas execuções vai usar.
    **Vaga de conta:** no grátis, cada conta diferente consultada no mês ocupa 1 das 2 vagas e não devolve, nem desligando. Confirme a conta certa pelo nome e ID **antes** de consultar dentro dela.
10. **Conta usada por outra pessoa no Pipeboard** não funciona no plano grátis (trava de "dono"). Se der erro de conta "já em uso", explique isso.
11. **GAQL não junta recursos à vontade:** `campaign_budget` não pode ser lido numa consulta `FROM campaign_criterion`. Na dúvida, use `google_ads_check_campaign_serving`, que já traz quase tudo.
12. **Snippet em português:** a ferramenta `google_ads_create_structured_snippet` só aceita cabeçalhos em inglês. Pelo lote, `"header": "Serviços"` e `"Tipos"` funcionam (testados). `"Bairros"` é recusado (`INVALID_FORMAT`), mesmo estando na lista do Google: use só os dois.
13. **Recurso não se apaga pela API** (sitelink, frase, snippet): só dá pra desligar da campanha. Remover a campanha tira as ligações; o recurso fica solto na biblioteca, sem aparecer em anúncio.
14. **Filtro de outro recurso precisa estar no SELECT.** Se a consulta é `FROM keyword_view` e filtra `campaign.status`, o `campaign.status` também tem que ir no SELECT, senão o Google recusa com `EXPECTED_REFERENCED_FIELD_IN_SELECT_CLAUSE`. Vale pra qualquer filtro em campo de outro recurso e pra `segments.*` (menos `segments.date`). Se aparecer esse erro, acrescente no SELECT o campo que ele citar e rode de novo, sem mudar mais nada.
15. **Conta suspensa ou cancelada** recusa qualquer gravação, inclusive a simulação (`ACTION_NOT_PERMITTED_FOR_SUSPENDED_ACCOUNT`). Não gaste execução conferindo antes: o erro aparece na gravação (às vezes já no Planejador). Explique que se resolve no Google Ads e que o plano fica salvo pra subir depois.
16. **`change_event`** só aceita os últimos 30 dias e exige `LIMIT`: use `DURING LAST_14_DAYS` (o `LAST_30_DAYS` cai no limite e é recusado).
17. **Nome de campanha repetido** (`DUPLICATE_CAMPAIGN_NAME`): a conta já tem uma campanha com esse nome. Proponha o mesmo nome com um complemento (ex.: a data) e pergunte antes de reenviar.
18. **Idioma do preço:** `languageCode: "pt-BR"`. Só `"pt"` é recusado (`INVALID_LANGUAGE_CODE`).
19. **Nunca fixe título** (`pinnedField`): os 15 vão soltos e o Google combina.
20. **Anúncio barrado por política na criação** (`POLICY_FINDING`, "policy topics of type PROHIBITED", apontando um `adGroupAdOperation`): o lote é tudo ou nada, então nada dele entra (grupos, palavras e negativas também). A mensagem não diz qual texto foi barrado, e pode ser a **combinação** dos textos: em 09/11/26, cada título e cada descrição passou sozinho, mas o anúncio inteiro não, e os mesmos textos passaram em outro anúncio. **Não troque texto no chute e reenvie o lote**, porque cada tentativa gasta 1 execução e o texto novo pode disparar de novo. Faça assim:
    1. Confira se a página abre pro robô do Google (não gasta execução): `curl -s -o /dev/null -w "%{http_code}" -A "AdsBot-Google (+http://www.google.com/adsbot.html)" "<link>"` tem que dar `200` (no PowerShell, `curl.exe`).
    2. Mande **um** lote de teste com `validate_only: true` (não grava nada, 1 execução): um grupo temporário (`C/adGroups/-1`) e várias versões do anúncio barrado, uma por operação: o anúncio inteiro, ele sem cada título suspeito, ele sem cada descrição e cada texto novo sozinho (com 3 títulos e 2 descrições que já passaram). O erro lista o número de cada versão recusada (`mutate_operations[N]`); as que não aparecem passaram.
    3. Escolha uma versão que **passou no teste** (ex.: sem 1 título ou sem 1 descrição), diga ao usuário o que sai e pergunte. Não invente um texto novo sem testar.
    4. Suba o lote com essa versão. O texto que ficou de fora o usuário pode tentar depois no Google Ads, que mostra o motivo exato.

## Subida em lote (testada em 02/11/26)
Use `google_ads_execute_mutate` com `resource_type: "googleAds"`. Cada item da lista é uma operação embrulhada; IDs negativos (`-1`, `-2`) são temporários e ligam itens do mesmo lote. Nomes de campo em camelCase. Troque `C` por `customers/<conta>` e `CAMP` por `C/campaigns/<id>`.

**Lote 1, configurações:**
```json
[{"campaignCriterionOperation": {"remove": "CAMP_CRITERIA~2076"}},
 {"campaignCriterionOperation": {"create": {"campaign": "CAMP", "location": {"geoTargetConstant": "geoTargetConstants/<cidade>"}}}},
 {"campaignCriterionOperation": {"create": {"campaign": "CAMP", "language": {"languageConstant": "languageConstants/1014"}}}},
 {"campaignCriterionOperation": {"create": {"campaign": "CAMP", "adSchedule": {"dayOfWeek": "MONDAY", "startHour": 0, "startMinute": "ZERO", "endHour": 24, "endMinute": "ZERO"}}}},
 {"campaignOperation": {"update": {"resourceName": "CAMP", "geoTargetTypeSetting": {"positiveGeoTargetType": "PRESENCE"}}, "updateMask": "geo_target_type_setting.positive_geo_target_type"}}]
```
(`CAMP_CRITERIA` = `C/campaignCriteria/<id da campanha>`.) **Raio em km a partir do endereço:** mande o lote 1 sem a linha da cidade e depois chame `google_ads_set_geo_targeting` com `proximity` (`address`, `city_name`, `country_code: "BR"`, `radius` e `radius_units: "KILOMETERS"`). Gasta 1 execução a mais e o conector acha o endereço sozinho. Se a resposta ou a conferência trouxer o centro do raio (latitude e longitude), guarde no `negocio.md` pra próxima campanha; não gaste consulta extra só pra isso.
**Raio no próprio lote 1 (testado em 09/11/26):** se o `negocio.md` já tem a latitude e a longitude do centro, ponha o raio no lote 1, sem a chamada extra (economiza 1 execução). Graus × 1.000.000, sem casa decimal:
```json
{"campaignCriterionOperation": {"create": {"campaign": "CAMP", "proximity": {"geoPoint": {"latitudeInMicroDegrees": -22905600, "longitudeInMicroDegrees": -47060800}, "radius": 3, "radiusUnits": "KILOMETERS"}}}}
```
**Excluir uma cidade que o raio pega** (ex.: do outro lado de um rio, onde o negócio não atende), no mesmo lote 1 (testado em 09/11/26): `{"campaignCriterionOperation": {"create": {"campaign": "CAMP", "negative": true, "location": {"geoTargetConstant": "geoTargetConstants/<id da cidade>"}}}}`. O código da cidade sai da mesma consulta de `geo_target_constant` da etapa 2.
**Programação:** repita a linha do `adSchedule` 7 vezes, uma por dia: `MONDAY`, `TUESDAY`, `WEDNESDAY`, `THURSDAY`, `FRIDAY`, `SATURDAY`, `SUNDAY`, sempre `startHour: 0` e `endHour: 24` (24 = meia-noite do fim do dia). Minutos só aceitam `ZERO`, `FIFTEEN`, `THIRTY` ou `FORTY_FIVE`. Com as 7 linhas, a campanha roda o dia todo e o relatório de dia da semana já fica separado pra ajustar lance por dia (`bidModifier` no critério de cada dia).

**Lote 2, estrutura** (repita o bloco por grupo, trocando `-1` por `-2`...):
```json
[{"adGroupOperation": {"create": {"resourceName": "C/adGroups/-1", "campaign": "CAMP", "name": "Grupo 1: <Tema Do Grupo>", "status": "PAUSED", "type": "SEARCH_STANDARD"}}},
 {"adGroupCriterionOperation": {"create": {"adGroup": "C/adGroups/-1", "status": "ENABLED", "keyword": {"text": "<palavra>", "matchType": "PHRASE"}}}},
 {"adGroupAdOperation": {"create": {"adGroup": "C/adGroups/-1", "status": "PAUSED", "ad": {"finalUrls": ["<link>"], "responsiveSearchAd": {"headlines": [{"text": "..."}], "descriptions": [{"text": "..."}], "path1": "...", "path2": "..."}}}}},
 {"campaignCriterionOperation": {"create": {"campaign": "CAMP", "negative": true, "keyword": {"text": "<negativa>", "matchType": "PHRASE"}}}}]
```
Nunca fixe título (nada de `pinnedField`). Os grupos vão sem `cpcBidMicros`: com Maximizar cliques ou Maximizar conversões, quem dá o lance é o Google.

**Lote 3, recursos (tudo numa chamada só):** crie cada recurso com um ID temporário (`-1`, `-2`...) e ligue cada um à campanha. Pra 6 sitelinks, 8 frases, 2 snippets, ligação e preço, são 18 recursos + 18 ligações num lote só.
```json
[{"assetOperation": {"create": {"resourceName": "C/assets/-1", "finalUrls": ["https://site.com.br/instalacao#1"], "sitelinkAsset": {"linkText": "Orçamento Pelo WhatsApp", "description1": "Resposta em minutos", "description2": "Sem compromisso e sem taxa"}}}},
 {"assetOperation": {"create": {"resourceName": "C/assets/-2", "finalUrls": ["https://site.com.br/instalacao#2"], "sitelinkAsset": {"linkText": "...", "description1": "...", "description2": "..."}}}},
 {"assetOperation": {"create": {"resourceName": "C/assets/-7", "calloutAsset": {"calloutText": "Garantia De 1 Ano"}}}},
 {"assetOperation": {"create": {"resourceName": "C/assets/-15", "structuredSnippetAsset": {"header": "Serviços", "values": ["Instalação", "Limpeza", "Manutenção", "Conserto"]}}}},
 {"assetOperation": {"create": {"resourceName": "C/assets/-16", "structuredSnippetAsset": {"header": "Tipos", "values": ["Split", "Janela", "Cassete", "Piso-teto"]}}}},
 {"assetOperation": {"create": {"resourceName": "C/assets/-17", "callAsset": {"countryCode": "BR", "phoneNumber": "1932320000"}}}},
 {"assetOperation": {"create": {"resourceName": "C/assets/-18", "priceAsset": {"type": "SERVICES", "languageCode": "pt-BR",
   "priceOfferings": [{"header": "Instalação Split", "description": "Até 12 mil BTUs", "price": {"amountMicros": "450000000", "currencyCode": "BRL"}, "finalUrl": "https://site.com.br/instalacao#p1"}, "... de 3 a 8 itens ..."]}}}},
 {"campaignAssetOperation": {"create": {"campaign": "CAMP", "asset": "C/assets/-1", "fieldType": "SITELINK"}}},
 {"campaignAssetOperation": {"create": {"campaign": "CAMP", "asset": "C/assets/-7", "fieldType": "CALLOUT"}}},
 {"campaignAssetOperation": {"create": {"campaign": "CAMP", "asset": "C/assets/-15", "fieldType": "STRUCTURED_SNIPPET"}}},
 {"campaignAssetOperation": {"create": {"campaign": "CAMP", "asset": "C/assets/-17", "fieldType": "CALL"}}},
 {"campaignAssetOperation": {"create": {"campaign": "CAMP", "asset": "C/assets/-18", "fieldType": "PRICE"}}}]
```
- **Hack do Matheus:** cada sitelink com a página da campanha + `#1`, `#2`... (links diferentes, todos na página que converte). O validador barra link repetido.
- **Snippet:** cabeçalho só `Serviços` ou `Tipos` (testados; `Bairros` é recusado), de 3 a 10 valores.
- **Preço:** de 3 a 8 itens; só se o negócio aceita mostrar preço. `languageCode: "pt-BR"`; `type`: `SERVICES` (serviços) ou `SERVICE_TIERS` (planos); em plano mensal, cada item leva `"unit": "PER_MONTH"`. Sem `priceQualifier` (não testado). Ligação: o telefone só com números e DDD (ex.: `1932320000`).
- **Nome da empresa, logo e fotos:** a skill não sobe (dependem do negócio). Avise no plano final e no resumo pro usuário conferir e adicionar no Google Ads.
- **Já confirmado na API (02 e 05/11/26):** sitelink, frase de destaque, snippets "Serviços" e "Tipos", preço (`pt-BR`, `SERVICE_TIERS`, `PER_MONTH`). **Ainda a confirmar no primeiro uso:** ligação e metas de conversão. Como o lote é tudo ou nada, um formato recusado não deixa nada pela metade: o Google diz o campo com problema, você corrige e manda de novo. Pra testar sem gravar, mande o lote com `validate_only: true` (gasta 1 execução).

**Lote 4, metas de conversão** (só se a etapa 4 mostrou que precisa; vai por último, sozinho):
```json
[{"campaignConversionGoalOperation": {"update": {"resourceName": "C/campaignConversionGoals/<id da campanha>~SUBMIT_LEAD_FORM~WEBSITE", "biddable": true}, "updateMask": "biddable"}},
 {"campaignConversionGoalOperation": {"update": {"resourceName": "C/campaignConversionGoals/<id da campanha>~PURCHASE~WEBSITE", "biddable": false}, "updateMask": "biddable"}}]
```
Uma linha por par categoria~origem das conversões ativas da conta: `true` nas de contato que o usuário escolheu, `false` nas outras. O nome segue a documentação do Google (`customers/{conta}/campaignConversionGoals/{campanha}~{categoria}~{origem}`), e mudar qualquer uma já faz a campanha usar metas próprias em vez do padrão da conta. Ainda não testado numa conta: se o Google recusar, a campanha já está inteira; avise que a meta se ajusta no Google Ads (Campanha › Configurações › Metas de conversão).

## Sem conector?
A skill continua útil: faz as etapas 1 a 5 (briefing, palavras, estrutura e anúncios) e entrega uma planilha pro **Google Ads Editor** em vez de subir pela API. Pra volume de busca, peça ao usuário o export do Planejador de palavras-chave (CSV).
