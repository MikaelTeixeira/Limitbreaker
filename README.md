# Limit Breaker

Aplicativo mobile Flutter para acompanhar evolução física e esportiva com disciplina, clareza e gamificação sóbria.

> “Os limites só existem se você os deixar existir.”

## Estado atual

A aplicação inicia sem registros fictícios: zero treinos, atividades, amigos, conquistas e pontuação. O onboarding inclui a escolha de modalidades primária, secundária e terciária para o Ranking. O ambiente de desenvolvimento possui PostgreSQL local, API autenticada e persistência de contas, onboarding, sugestões e treinos. A integração remota e o Google OAuth permanecem pendentes.

## Requisitos

- Flutter 3.47.2 (stable) ou compatível
- Dart 3.13.2 ou compatível
- PostgreSQL 16 ou compatível para o ambiente local
- Android Studio/SDK para Android
- Xcode em macOS para iOS

## Executar

```bash
flutter pub get
flutter run
```

No Windows, ao executar o comando na raiz do projeto, o `flutter.bat`
versionado prepara a API PostgreSQL local antes de abrir o aplicativo. Crie
`server/.env` a partir de `server/.env.example`; a configuração completa está
em [docs/LOCAL_DATABASE.md](docs/LOCAL_DATABASE.md).

Qualidade:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

O build Android foi revalidado no toolchain local com Android SDK 37. Na primeira execução, o Gradle pode demorar enquanto baixa os artefatos nativos do Flutter e instala o CMake.

## Arquitetura

O código usa organização feature-first com separação proporcional entre apresentação, domínio e dados. Riverpod fornece injeção de dependência e estado; GoRouter mantém rotas declarativas; `shared_preferences` mantém o estado auxiliar de conclusão do onboarding no dispositivo. Contas, onboarding, sugestões e treinos são persistidos no PostgreSQL exclusivamente pela API Dart local.

```text
lib/
  app/                 tema, aplicação e rotas
  core/widgets/        componentes e painters reutilizáveis
  features/            onboarding, dashboard, ranking, social e perfil
  shared/models/       modelos compartilhados
  shared/repositories/ estado provisório e providers
test/                  domínio, fluxo e regressão visual
server/                API Dart autenticada e inicialização do banco
database/migrations/   esquema incremental do PostgreSQL local
```

Detalhes: [plano de execução](docs/EXECUTION_PLAN.md), [arquitetura](docs/architecture.md), [estrutura do código](docs/code-structure.md), [regras de domínio](docs/domain-rules.md), [sistema de ranking](docs/ranking-system.md) e [backlog](docs/BACKLOG.md).

## Dependências adicionadas

- `go_router`: navegação declarativa.
- `flutter_riverpod`: injeção de dependência e estado previsível.
- `shared_preferences`: estado auxiliar local da conclusão do onboarding.
- `flutter_secure_storage`: armazenamento do token de sessão no dispositivo.
- API Dart em `server/`: autenticação e fronteira segura entre o Flutter e o PostgreSQL.

Credenciais do PostgreSQL ficam apenas no arquivo local e ignorado `server/.env` ou na variável de ambiente `DATABASE_URL`. Nenhuma senha ou chave é incorporada ao Flutter.

## Limitações atuais

- Ranking global, amigos e conquistas ainda são locais ou demonstrativos; contas, perfil autenticado, onboarding, sugestões e treinos já possuem integração com a API local.
- Perguntas de saúde, histórico familiar, termos e níveis são provisórios.
- Com menos de três categorias, o ranking retorna resultado provisório sem pontuação oficial.
- Edição de treinos, atividades, chat, scanner QR e notificações reais estão planejados.
- Os gráficos mostram valores normalizados simulados, não diagnóstico fisiológico.
- Build iOS requer macOS; o build Android de depuração está validado no toolchain local.
