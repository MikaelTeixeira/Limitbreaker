# Log de desenvolvimento

## 2026-08-06 — Fase 1

- Inicializado projeto Flutter 3.44.4 / Dart 3.12.2 para Android e iOS.
- Adicionados `go_router`, `flutter_riverpod` e `shared_preferences` via `flutter pub add`.
- Implementados arquitetura feature-first, tema, rotas, mocks, domínio de Ranking e vertical slice navegável.
- Implementados onboarding em seis etapas, Dashboard, Ranking, Amigos, Conquistas, Perfil e gráficos dinâmicos.
- Criados nove testes funcionais/de domínio e um golden mobile de regressão visual.
- `dart format`, `flutter analyze` e `flutter test` concluídos com sucesso.
- `flutter build apk --debug` foi tentado duas vezes, mas o processo Gradle não produziu resultado dentro de 2 e 5 minutos; revalidação pendente.

## 2026-08-06 — Fase 2 iniciada

- Iniciada a implementação incremental de treinos e atividades com armazenamento local em memória.
- Backend, autenticação e sincronização continuam fora do escopo até decisão técnica explícita.
- Implementados modelos de séries e exercícios realizados, repositório local de sessões e rotina demonstrativa editável.
- Implementadas telas para escolher rotina, iniciar treino, informar séries/repetições/carga e concluir localmente.
- Concluída a Fase 2 com registro de atividades, histórico e recorde pessoal de corrida, todos locais em memória.

## 2026-08-07 — Fase 3 iniciada

- Adicionados estados explícitos para convite de amizade e operações locais de envio, aceite e recusa.
- A tela Amigos agora diferencia convites recebidos e enviados; aceitar um recebido adiciona a pessoa ao círculo local. QR, código de convite e chat seguem demonstrativos até a integração do backend.

## 2026-08-07 — Fase 4 iniciada

- Adicionada base de Supabase/PostgreSQL: configuração segura por `--dart-define`, exemplo de ambiente e migração inicial com RLS.
- Nenhum projeto externo, URL ou chave foi configurado; a aplicação segue usando dados locais até a conexão ser fornecida.
- Google Auth foi priorizado para a Fase 4, após criação do projeto Supabase e configuração segura de OAuth (Client ID, Client Secret, callbacks e deep links).

## 2026-08-07 — Ambiente Android

- Instaladas as Android Command-line Tools oficiais e aceitas as licenças do Android SDK.
- `flutter doctor` passou a validar o toolchain Android.
- O AVD existente `Medium_Phone` permaneceu offline após cold boot; recriação/ajuste do AVD fica pendente.

## 2026-08-10 — Persistência local iniciada

- Criado o banco PostgreSQL local `limitbreaker` e aplicada a migração inicial de perfis, avaliações de saúde, respostas descritivas e sugestões de treino.
- A aplicação Flutter ainda não acessa o banco diretamente: a próxima fatia cria uma API local autenticada, sem senha de banco no APK.
- Definida e testada a classificação autorrelatada dos quatro perfis de treino.

## 2026-08-10 — Estados iniciais e modalidades

- Removidos os dados fictícios pré-carregados de treino, amigos, conquistas, ranking e gráficos. Uma conta nova inicia com zero registros e posição global inicial #1 enquanto não houver outra pessoa cadastrada.
- Adicionado carrossel de modalidades no onboarding, com seleção obrigatória e sem repetição para os pesos 75/15/10.
- Adicionadas ilustrações temporárias geradas por IA em preto e branco para musculação, corrida, ciclismo, natação, futebol e lutas.
- Incluído campo obrigatório de e-mail no onboarding; o esquema PostgreSQL já garante unicidade por perfil.

## 2026-08-11 — Registro manual de treinos

- A navegação inferior substituiu Conquistas por Treinos, com ícone de halter. Conquistas permanecem disponíveis na seção Perfil.
- Criado fluxo de lançamento manual: escolha de modalidade, pace para corrida/ciclismo, distância para natação e montagem de musculação por grupo muscular.
- A musculação permite pesquisar no catálogo, adicionar exercícios e informar séries, repetições e carga antes de finalizar. Antebraço foi incluído entre os grupos musculares.
- As imagens de execução permanecem explicitamente marcadas como “Imagem pendente” até a entrega das fotos reais.
- Nenhum treino é criado por demonstração: o histórico só é atualizado após “Finalizar treino”. Nesta fatia, os lançamentos ainda vivem no repositório local em memória; a persistência pelo servidor PostgreSQL continua como próximo passo de backend.

## 2026-08-17 — Persistência local concluída

- Aplicada migração de sessões, treinos, exercícios, séries e cargas no PostgreSQL local.
- Implementada API local autenticada para cadastro, login e lançamentos de treino; senhas usam bcrypt, tokens de sessão são aleatórios e apenas seus hashes são persistidos.
- O Flutter envia o cadastro/login à API e usa armazenamento seguro do dispositivo para o token. “Finalizar treino” envia musculação, corrida, ciclismo ou natação ao PostgreSQL, sem dados de demonstração.
- Histórico de treinos consulta a API local. `flutter test` e a checagem de conexão da API com PostgreSQL foram concluídos com sucesso.

## 2026-08-17 — Estágios de Ranking

- Definidos e implementados 15 estágios: Bronze, Prata, Ouro, Diamante e Platina, cada um em I, II e III.
- A apresentação usa a escala normalizada provisória de 0–100, dividida em faixas iguais até que a normalização oficial por modalidade seja definida.

## 2026-08-17 — Catálogo de exercícios

- Criadas as tabelas `exercise_categories` e `exercises`, com chave estrangeira, restrições de unicidade e índices de consulta.
- Incluídos 86 exercícios de academia em 10 categorias, sem inserir exercícios, treinos ou contas fictícias.

## 2026-08-17 — Contas locais

- Criada a tabela `users` como fonte de autenticação local, separada do perfil físico e com vínculo opcional via chave estrangeira.
- Inserida a conta local solicitada para Mikael Teixeira; apenas o hash bcrypt da senha foi armazenado.

## 2026-08-17 — Fluxo único de cadastro

- Removida a tela duplicada de dados básicos antes do onboarding.
- O cadastro abre diretamente o onboarding, cuja primeira etapa reúne nome de exibição, e-mail, nome de usuário, senha, idade, altura em cm e peso em kg.

## 2026-08-17 — Administração local

- Adicionado tipo de conta `standard`/`administrator`, estado de ativação e sessões vinculadas à conta.
- Mikael Teixeira foi configurado como administrador.
- Criado painel administrativo exclusivo para criar eventos, administrar exercícios e ativar/desativar contas, promover/rebaixar administradores e redefinir senhas.
