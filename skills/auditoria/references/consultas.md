# As 11 leituras da auditoria

Rode todas ao mesmo tempo. Cada uma gasta 1 execução do Pipeboard. Use como estão, sem acrescentar campo. Valores em micros: divida por 1.000.000. Se o Google recusar alguma, corrija uma vez (o erro diz o campo); se falhar de novo, marque os itens dela como "não conferido" e siga.

## 1. Campanhas (configuração, lance, verba e números)
```sql
SELECT customer.currency_code, campaign.id, campaign.name, campaign.status, campaign.advertising_channel_type,
       campaign.bidding_strategy_type, campaign.bidding_strategy_system_status,
       campaign.primary_status, campaign.primary_status_reasons,
       campaign.maximize_conversions.target_cpa_micros, campaign.target_spend.cpc_bid_ceiling_micros,
       campaign.network_settings.target_google_search, campaign.network_settings.target_search_network,
       campaign.network_settings.target_content_network,
       campaign.geo_target_type_setting.positive_geo_target_type, campaign_budget.amount_micros,
       metrics.cost_micros, metrics.clicks, metrics.impressions, metrics.conversions,
       metrics.search_impression_share, metrics.search_budget_lost_impression_share,
       metrics.search_rank_lost_impression_share
FROM campaign
WHERE segments.date DURING LAST_30_DAYS AND campaign.status != 'REMOVED'
```
Campanha pausada também vem (pra ver se existe a da marca, por exemplo). `bidding_strategy_system_status` começando com `LEARNING` = o Google está aprendendo; `LIMITED_BY_BUDGET` = falta verba; `LIMITED_BY_DATA` = poucas conversões; `MISCONFIGURED...` = configuração errada.

## 2. Conversões da conta
```sql
SELECT conversion_action.id, conversion_action.name, conversion_action.status, conversion_action.primary_for_goal,
       conversion_action.category, conversion_action.origin, conversion_action.type
FROM conversion_action
WHERE conversion_action.status = 'ENABLED'
```

## 3. O que cada conversão registrou, por campanha
```sql
SELECT campaign.id, campaign.name, campaign.status, segments.conversion_action_name,
       metrics.conversions, metrics.all_conversions
FROM campaign
WHERE segments.date DURING LAST_30_DAYS AND campaign.status != 'REMOVED'
```
`conversions` maior que zero = aquela ação conta como resultado nessa campanha (é com ela que o Google dá lance). Só em `all_conversions` = registra, mas não conta. É a prova mais segura do que cada campanha está contando.

## 4. Meta de cada campanha
```sql
SELECT campaign.id, campaign.name, campaign.status, campaign_conversion_goal.category,
       campaign_conversion_goal.origin, campaign_conversion_goal.biddable
FROM campaign_conversion_goal
WHERE campaign.status = 'ENABLED'
```
`biddable = true` numa categoria que não é o objetivo do negócio (ex.: `PURCHASE` num negócio de contato) = a campanha está contando a meta errada. Se a leitura 3 mostra resultado contando numa categoria que aqui aparece desligada, a campanha usa uma **meta personalizada** (escolhida ação por ação): vale o que a leitura 3 mostra.

## 5. Local, idioma e horário
```sql
SELECT campaign.id, campaign.status, campaign_criterion.type, campaign_criterion.negative,
       campaign_criterion.location.geo_target_constant, campaign_criterion.proximity.radius,
       campaign_criterion.proximity.radius_units, campaign_criterion.proximity.address.city_name,
       campaign_criterion.proximity.address.street_address,
       campaign_criterion.proximity.geo_point.latitude_in_micro_degrees,
       campaign_criterion.proximity.geo_point.longitude_in_micro_degrees,
       campaign_criterion.language.language_constant, campaign_criterion.ad_schedule.day_of_week,
       campaign_criterion.ad_schedule.start_hour, campaign_criterion.ad_schedule.end_hour,
       campaign_criterion.bid_modifier
FROM campaign_criterion
WHERE campaign_criterion.type IN ('LOCATION', 'PROXIMITY', 'LANGUAGE', 'AD_SCHEDULE') AND campaign.status = 'ENABLED'
```
Português é `languageConstants/1014`. Horário certo: 7 linhas, uma por dia (ou só os dias em que o negócio atende). Raio (`PROXIMITY`): confira a unidade e o centro (endereço ou, no raio criado pela `/subir-campanha`, latitude e longitude); mais de um raio na mesma campanha ou centro longe do negócio é ATENÇÃO.

## 6. Palavras-chave
```sql
SELECT campaign.id, campaign.name, campaign.status, ad_group.id, ad_group.name, ad_group.status,
       ad_group_criterion.criterion_id, ad_group_criterion.keyword.text, ad_group_criterion.keyword.match_type,
       ad_group_criterion.status, ad_group_criterion.negative, ad_group_criterion.system_serving_status,
       ad_group_criterion.quality_info.quality_score,
       ad_group_criterion.quality_info.creative_quality_score,
       ad_group_criterion.quality_info.post_click_quality_score,
       ad_group_criterion.quality_info.search_predicted_ctr,
       metrics.impressions, metrics.clicks, metrics.cost_micros, metrics.conversions
FROM keyword_view
WHERE segments.date DURING LAST_30_DAYS AND ad_group.status = 'ENABLED' AND campaign.status = 'ENABLED'
  AND ad_group_criterion.status = 'ENABLED' AND ad_group_criterion.negative = FALSE
ORDER BY metrics.cost_micros DESC
LIMIT 1000
```
Palavra sem impressão vem com 0. As negativas do grupo ficam de fora.

## 7. Termos de pesquisa (as 60 buscas que mais gastaram)
```sql
SELECT campaign.id, campaign.advertising_channel_type, ad_group.id, ad_group.name,
       search_term_view.search_term, search_term_view.status,
       segments.keyword.info.text, segments.keyword.info.match_type,
       metrics.impressions, metrics.clicks, metrics.cost_micros, metrics.conversions
FROM search_term_view
WHERE segments.date DURING LAST_30_DAYS AND campaign.advertising_channel_type = 'SEARCH'
ORDER BY metrics.cost_micros DESC
LIMIT 60
```

## 8. Anúncios
```sql
SELECT campaign.id, campaign.name, campaign.status, ad_group.id, ad_group.name, ad_group.status,
       ad_group_ad.ad.id, ad_group_ad.status, ad_group_ad.ad_strength, ad_group_ad.policy_summary.approval_status,
       ad_group_ad.ad.responsive_search_ad.headlines, ad_group_ad.ad.responsive_search_ad.descriptions,
       ad_group_ad.ad.final_urls, metrics.impressions, metrics.clicks, metrics.ctr, metrics.conversions
FROM ad_group_ad
WHERE ad_group_ad.ad.type = 'RESPONSIVE_SEARCH_AD' AND segments.date DURING LAST_30_DAYS
  AND campaign.status = 'ENABLED' AND ad_group.status = 'ENABLED' AND ad_group_ad.status != 'REMOVED'
```
Título fixado aparece com `pinnedField` dentro de `headlines`.

## 9. Negativas
`google_ads_get_negative_keywords` com `include_shared_lists: true`: traz as negativas da conta inteira (campanhas e grupos) e, das listas compartilhadas, só o nome e o tamanho. Se houver lista com palavras, leia o conteúdo (`google_ads_get_shared_negative_keyword_lists`, 1 execução a mais).

## 10. Recursos
`google_ads_get_extensions` com `status_filter: "ENABLED"`: sitelinks, frases de destaque, snippets e ligação da conta toda. Considere só os das campanhas ativas. Preço não aparece nessa leitura.

## 11. Recursos ligados ao grupo
A leitura 10 só traz o que está ligado à campanha. Antes de dizer que falta sitelink, frase ou snippet, leia também os do grupo (1 execução):
```sql
SELECT campaign.status, ad_group.id, ad_group.name, ad_group.status, ad_group_asset.field_type, ad_group_asset.status,
       asset.sitelink_asset.link_text, asset.callout_asset.callout_text, asset.structured_snippet_asset.header,
       asset.final_urls
FROM ad_group_asset
WHERE ad_group_asset.status = 'ENABLED' AND campaign.status = 'ENABLED' AND ad_group.status = 'ENABLED'
  AND ad_group_asset.field_type IN ('SITELINK', 'CALLOUT', 'STRUCTURED_SNIPPET', 'CALL')
```
Só falta recurso num grupo se ele não tiver nem o do grupo nem o da campanha. Confira também se o link de cada sitelink do grupo leva pra página daquele grupo.
