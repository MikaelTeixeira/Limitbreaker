# Regras de domínio

## Onboarding

- O primeiro acesso exibe boas-vindas e sete etapas curtas.
- Objetivo, e-mail, dados básicos, modalidades, respostas provisórias e consentimento são obrigatórios para avançar.
- Cada perfil possui exatamente um e-mail, validado na interface e único no banco de dados.
- A conclusão é persistida localmente por uma abstração de armazenamento.
- Saúde e histórico familiar são estruturas provisórias, não diagnóstico.
- Textos jurídicos são placeholders e ainda exigem validação formal.
- Condições pessoais e histórico familiar são autorrelatados, com opção de declarar ausência ou descrever o problema; não constituem diagnóstico.
- Perfil 1 exige nenhuma preocupação informada e rotina ativa; Perfil 2 exige nenhuma preocupação informada, mas rotina sedentária; Perfil 3 é usado quando há condição pessoal ou histórico familiar relatado; Perfil 4 depende de indicação explícita de necessidade de treino muito leve/adaptado.
- O Perfil 4 não é prescrição fisioterapêutica: a interface deve orientar busca de profissional habilitado antes de iniciar treino.
- O onboarding exige três modalidades distintas, ordenadas como primária (75%), secundária (15%) e terciária (10%). Essa ordem define os pesos quando houver pontuação real registrada.

## Ranking

- Apenas as três maiores pontuações normalizadas entram no total geral.
- Os pesos são 75%, 15% e 10%, nessa ordem.
- Categorias adicionais permanecem visíveis, mas não alteram o total se estiverem fora do top 3.
- Uma ou duas categorias geram resultado provisório, sem inventar redistribuição de pesos.
- Pontuações de entrada são limitadas à escala 0–100 pelo normalizador provisório.

## Conquistas

- Conquistas oficiais podem influenciar Ranking.
- Checkpoints pessoais aparecem no perfil/histórico, mas não geram pontos oficiais.
- A influência é uma propriedade explícita do modelo, nunca inferida do título.

## Treinos e atividades

- Textos que se dirigem à pessoa devem usar seu primeiro nome; termos genéricos como “Atleta” e “Usuário” não são usados como forma de tratamento.
- Uma sessão é iniciada a partir de uma rotina e permanece local, em memória, nesta etapa.
- A conclusão registra séries, repetições, carga, duração e observação opcional.
- Séries devem possuir pelo menos uma repetição; carga não pode ser negativa.
- Encerrar uma sessão inexistente é um erro explícito, nunca um registro silencioso.
- O lançamento manual de musculação exige grupo muscular, ao menos um exercício, séries, repetições e carga. A lista de exercícios é apenas um catálogo de referência; um exercício não entra no histórico até a confirmação de “Finalizar treino”.
- Corrida e ciclismo exigem duração e pace no formato min:seg/km. Natação exige duração e distância em metros.
- Histórico, recordes e atividades esportivas ainda estão em desenvolvimento nesta Fase 2.

## Privacidade

- Nenhuma resposta de saúde deve ser registrada em logs, analytics ou mensagens de erro.
- O aplicativo não afirma conformidade jurídica definitiva nem substituição de profissionais.
- Backend, transmissão e exclusão de dados ainda dependem de decisões futuras.
