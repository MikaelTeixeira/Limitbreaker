# Regras de domínio

## Onboarding

- O primeiro acesso exibe boas-vindas e sete etapas curtas.
- Objetivo, e-mail, dados básicos, modalidades, respostas provisórias e consentimento são obrigatórios para avançar.
- Cada perfil possui exatamente um e-mail, validado na interface e único no banco de dados.
- A conclusão possui estado auxiliar no dispositivo e é persistida, junto às respostas, no PostgreSQL pela API autenticada.
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
- A escala oficial de apresentação possui 15 estágios, em ordem crescente: Bronze I, Bronze II, Bronze III, Prata I, Prata II, Prata III, Ouro I, Ouro II, Ouro III, Diamante I, Diamante II, Diamante III, Platina I, Platina II e Platina III.
- Os 15 estágios dividem a pontuação normalizada 0–100 em faixas iguais de 6,6667 pontos. Platina III é o estágio máximo.

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
- Registro e histórico de treinos já são persistidos pela API local. Edição completa, imagens de execução e consolidação de recordes para todas as modalidades permanecem em desenvolvimento.
- Sugestões usam rotinas predefinidas e explicáveis, selecionadas pela API conforme modalidade e perfil de treino, e ficam registradas para o perfil autenticado. IA permanece fora do MVP atual.
- Atividades de corrida, ciclismo e natação usam `workout_sessions` como fonte única; duração e distância devem ser positivas.
- Corrida registra maior distância e melhor pace por quilômetro; ciclismo registra maior distância e maior velocidade média; natação registra maior distância e melhor pace por 100 metros.
- Em empate de recorde, prevalece a atividade mais antiga e, persistindo o empate, o menor identificador.
- Detalhes e exclusões de treino combinam o identificador solicitado com o perfil autenticado; registros de outras pessoas não são revelados.
- A exclusão de um treino de musculação remove seus exercícios e séries pela cascata do banco, após confirmação explícita na interface.

## Privacidade

- Nenhuma resposta de saúde deve ser registrada em logs, analytics ou mensagens de erro.
- O aplicativo não afirma conformidade jurídica definitiva nem substituição de profissionais.
- A transmissão local usa a API HTTP de desenvolvimento. Retenção, exclusão, sincronização remota e política formal de LGPD ainda dependem de decisões futuras.

## Perfil

- Nome, idade, altura e peso podem ser atualizados pelo perfil autenticado.
- Alterações de nome atualizam de forma transacional o perfil físico e a conta vinculada.
- O e-mail permanece somente leitura até existir uma política de alteração de credencial e reautenticação.

## Administração

- Contas possuem um tipo: `standard` ou `administrator`.
- Apenas administradores autenticados podem administrar exercícios, eventos e contas. A verificação é obrigatória na API, não apenas na interface.
- Um administrador pode ativar/desativar contas, alterar o tipo de conta e redefinir senhas. Uma conta não pode desativar a si mesma.
