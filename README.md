# Skills de Google Ads no método do Matheus Zappiello

Pacote de 7 skills pro Claude subir, otimizar e deixar no piloto campanhas de **Pesquisa** no Google Ads, seguindo o método ensinado no Curso de Tráfego Pago + IA.

| Skill | O que faz | Mexe na conta? |
|---|---|---|
| `/subir-campanha` | Monta a campanha com você aprovando 2 vezes (o que comprar e o plano final) e sobe tudo pausado, de uma vez | Sim, só com o seu OK, e tudo nasce pausado |
| `/revisar-termos` | Lê os termos de pesquisa e propõe negativas e palavras novas | Só o que você aprovar |
| `/revisar-palavras` | Índice de qualidade, palavras sem entrega, caras sem resultado, repetidas | Só o que você aprovar |
| `/revisar-lances` | Estratégia de lance x conversões, parcela perdida, ajuste por local, dia e dispositivo | Só o que você aprovar |
| `/revisar-anuncios` | Anúncio completo (15 títulos, 4 descrições), força, recursos e página | Só o que você aprovar |
| `/auditoria` | Raio-x da conta com nota de 0 a 100 e as 5 prioridades em R$ | Lê; o que você escolher corrigir, só com o seu OK |
| `/agendar-otimizacao` | Mostra o calendário num popup e deixa as revisões, a auditoria e os avisos agendados | Não: só cria as tarefas no Claude |

## O que você precisa
1. **Plano pago do Claude** (Pro ou Max) e o **app do Claude** instalado ([claude.ai/download](https://claude.ai/download)). As skills rodam na aba **Code**.
2. **Conector do Google Ads.** O pacote foi feito e testado com o **Pipeboard**, nesta ordem:
   1. Em [pipeboard.co](https://pipeboard.co), crie a conta e ligue o seu Google Ads lá dentro.
   2. No app do Claude: **Configurações › Conectores › Adicionar conector personalizado**, nome `Pipeboard`, URL `https://google-ads.mcp.pipeboard.co/`. Clique em Conectar e vincule a conta do Pipeboard.
   3. Plano grátis: 2 contas por mês e 30 execuções por semana. Uma campanha completa usa umas 11 execuções (a subida em si, 4): a skill só usa o conector pro que a subida precisa, e o resto (pagamento, campanhas antigas, conversão) você confere no Google Ads.
3. Uma conta de Google Ads **ativa** em que você é administrador. Conta suspensa não aceita criar nada.
4. **Mac ou Windows.** As skills trazem os comandos dos dois. O validador de anúncio tem três versões iguais: Python, Mac sem Python (`osascript`) e Windows sem Python (PowerShell). Você não precisa instalar nada além do app do Claude.

## Como instalar

### Jeito fácil: pedir pro Claude (aba Code)
Abra a aba **Code** na pasta que você vai usar pro Google Ads (veja "Use sempre a mesma pasta", em Como usar) e mande:
> Instala as skills de Google Ads deste link: `https://github.com/LeadsForYou5x/skills-google-ads` (siga a seção "Instalação pelo Claude" do README)

Ou, se você baixou o `.zip`:
> Instala as skills de Google Ads deste arquivo: `~/Downloads/skills-google-ads.zip` (siga a seção "Instalação pelo Claude" do README que está dentro dele)

Depois **abra uma conversa nova** e digite `/` pra ver as skills.

### Instalação pelo Claude
Comandos que o Claude roda (Mac e Linux). Se o .zip já estiver baixado, pule o `curl` e use o caminho dele no `unzip`:
```bash
curl -L -o /tmp/skills-google-ads.zip https://github.com/LeadsForYou5x/skills-google-ads/archive/refs/heads/main.zip
rm -rf /tmp/skills-google-ads && mkdir -p /tmp/skills-google-ads
unzip -q -o /tmp/skills-google-ads.zip -d /tmp/skills-google-ads
mkdir -p ~/.claude/skills
cp -R /tmp/skills-google-ads/*/skills/* ~/.claude/skills/
ls ~/.claude/skills
```
No Windows (PowerShell):
```powershell
Invoke-WebRequest -Uri https://github.com/LeadsForYou5x/skills-google-ads/archive/refs/heads/main.zip -OutFile "$env:TEMP\skills-google-ads.zip"
Expand-Archive "$env:TEMP\skills-google-ads.zip" -DestinationPath "$env:TEMP\skills-google-ads" -Force
New-Item -ItemType Directory -Force "$HOME\.claude\skills" | Out-Null
Copy-Item "$env:TEMP\skills-google-ads\*\skills\*" "$HOME\.claude\skills\" -Recurse -Force
```
Tem que aparecer: `agendar-otimizacao`, `auditoria`, `revisar-anuncios`, `revisar-lances`, `revisar-palavras`, `revisar-termos`, `subir-campanha`.

### Manual
Copie as 7 pastas de dentro de `skills/` para `~/.claude/skills/` (no Mac, a pasta `.claude` fica na sua pasta de usuário; aperte Cmd + Shift + . pra ver pastas ocultas).

### No chat comum (fora da aba Code)
Na pasta [`zips/`](zips) tem um `.zip` de cada skill. Baixe o da skill que você quer e envie em **Configurações › Capacidades › Skills**. O pacote foi feito e testado na aba Code: é nela que as skills guardam os arquivos de cada negócio.

## Como usar
- **Subir campanha:** digite só `/subir-campanha`. O Claude pergunta o negócio e o site; o resto você responde clicando, em 2 telas de opções. Depois você aprova só 2 vezes: **o que comprar** (palavras pelo Planejador e pela técnica do ABC, as de mais busca com CPC que cabe na verba, com a previsão de cliques e de contatos com a página convertendo 10%, 15% ou 20%) e **o plano final** (anúncio com 15 títulos e recursos completos: 6 sitelinks no hack `#1`, `#2`..., 8 frases de destaque, 2 snippets, ligação e preço; nome da empresa, logo e fotos você coloca no Google Ads). Com o OK, ele sobe tudo pausado, de uma vez, manda um resumo curto e oferece deixar o calendário de otimização agendado (você só marca o que quer).
- **Use sempre a mesma pasta:** crie uma pasta pro seu trabalho com o Claude (ex.: `Documentos/Claude`) e abra sempre ela na aba Code. As skills guardam tudo em `google-ads/<negocio>/` dentro dela: o perfil do negócio em `negocio.md` e uma pasta por campanha. Na próxima campanha ou revisão do mesmo negócio, o Claude lê esse perfil e só pergunta o que é novo.
- **Otimizar:** as 4 revisões e a auditoria mostram cada proposta explicada (o que fazer, por quê, o que muda na conta e o resultado esperado) e só gravam com o seu OK, no popup. O que foi mudado fica anotado em `google-ads/<negocio>/alteracoes.md`.
- **Calendário de otimização:** digite `/agendar-otimizacao` (a `/subir-campanha` abre ela sozinha no fim). Veja a seção abaixo.
- **Regra de ouro:** mexeu em lance ou verba, espere 7 a 14 dias antes de mexer de novo.

## Calendário de otimização (o Claude no piloto)
Cada revisão só lê a conta e salva um relatório em `google-ads/<negocio>/revisoes/`. Nada muda na conta sem o seu OK. O calendário segue a lista de otimização do método do Matheus:

| Quando | Skill | O que ela faz | Execuções do Pipeboard |
|---|---|---|---|
| Toda segunda, 8h | `/revisar-termos` | Negativas e palavras novas, tiradas dos termos de pesquisa | ~3 |
| Dias 1 e 15, 9h | `/revisar-anuncios` | Títulos fracos, força do anúncio, recursos e página | ~3 |
| Dia 10, 9h | `/revisar-palavras` | Índice de qualidade, palavra sem entrega e palavra cara sem resultado | ~2 |
| Dia 20, 9h | `/revisar-lances` | Verba (com o simulador do Google), lance e ajustes por dia, aparelho e cidade | 1 a 7 |
| 1º de jan, abr, jul e out, 10h | `/auditoria` | Nota da conta de 0 a 100 e as 5 prioridades | ~10 |

Tudo junto, numa conta, dá umas 30 execuções por mês (umas 7 por semana): cabe no plano grátis do Pipeboard (30 por semana), com folga pro trabalho na mão.

**Jeito fácil:** digite `/agendar-otimizacao`. Ela mostra todas as opções num popup (as 4 revisões, a auditoria e os avisos), cria as tarefas e oferece rodar uma na hora pra testar. A `/subir-campanha` e as revisões abrem ela sozinhas no fim.

**Na mão:** abra a aba Code **na mesma pasta** e peça (troque o negócio e a conta). A tarefa roda na pasta da conversa em que foi criada, então acha o `negocio.md` e salva os relatórios no lugar certo.
- "Toda segunda às 8h, use a skill revisar-termos no negócio <negócio> (conta <ID>) e salve as negativas e palavras novas sugeridas. Não aplique nada na conta."
- "Nos dias 1 e 15 de cada mês, às 9h, use a skill revisar-anuncios no negócio <negócio> (conta <ID>) e salve o relatório. Não aplique nada na conta."
- "Todo dia 10, às 9h, use a skill revisar-palavras no negócio <negócio> (conta <ID>) e salve o relatório. Não aplique nada na conta."
- "Todo dia 20, às 9h, use a skill revisar-lances no negócio <negócio> (conta <ID>) e salve o relatório. Não aplique nada na conta."
- "No dia 1º de janeiro, abril, julho e outubro, às 10h, use a skill auditoria no negócio <negócio> (conta <ID>) e salve o relatório."

**Pra aplicar:** quando um relatório sair, abra uma conversa nova e peça o que você aprovar (ex.: "aplica as negativas do relatório de termos de hoje").

**Avisos (a `/agendar-otimizacao` também cria):**
- "Todo dia às 9h, confira no conector Pipeboard o gasto de ontem de cada campanha ativa da conta <nome da conta> e me avise só se alguma gastou zero ou mais que o dobro do orçamento diário. Não altere nada." (gasta 7 execuções por semana)
- "Toda sexta às 17h, faça um resumo da semana da conta <nome da conta> pro cliente: gasto, cliques, contatos e o que foi alterado. Não altere nada."

Três cuidados:
1. **A primeira vez, rode na mão.** Abra a tarefa e clique em executar agora. Quando o Claude pedir permissão pra usar o Pipeboard (e pra salvar o relatório), escolha permitir sempre. As próximas execuções rodam sozinhas.
2. **Cada execução começa do zero:** o pedido tem que dizer tudo (conta, o que fazer, o que não fazer).
3. **Roda com o app aberto.** Se o computador estiver desligado, roda quando você abrir. Cada execução gasta execuções do Pipeboard (o vigia diário sozinho gasta 7 por semana).

## Segurança
- Nenhuma skill grava nada na conta sem o seu OK. Tarefa agendada só propõe.
- Campanhas, grupos e anúncios nascem **pausados**. Ativar é sempre decisão sua.
- Você pode revogar o acesso do conector em myaccount.google.com › Segurança › Apps de terceiros.

## Créditos
Método: Matheus Zappiello, Curso de Tráfego Pago + IA. Skills: Guilherme Silva.
