# Regras de domínio

## Onboarding

- O primeiro acesso exibe boas-vindas e seis etapas curtas.
- Objetivo, dados básicos, respostas provisórias e consentimento são obrigatórios para avançar.
- A conclusão é persistida localmente por uma abstração de armazenamento.
- Saúde e histórico familiar são estruturas provisórias, não diagnóstico.
- Textos jurídicos são placeholders e ainda exigem validação formal.

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

- Uma sessão é iniciada a partir de uma rotina e permanece local, em memória, nesta etapa.
- A conclusão registra séries, repetições, carga, duração e observação opcional.
- Séries devem possuir pelo menos uma repetição; carga não pode ser negativa.
- Encerrar uma sessão inexistente é um erro explícito, nunca um registro silencioso.
- Histórico, recordes e atividades esportivas ainda estão em desenvolvimento nesta Fase 2.

## Privacidade

- Nenhuma resposta de saúde deve ser registrada em logs, analytics ou mensagens de erro.
- O aplicativo não afirma conformidade jurídica definitiva nem substituição de profissionais.
- Backend, transmissão e exclusão de dados ainda dependem de decisões futuras.
