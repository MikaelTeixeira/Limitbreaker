# Limit Breaker

Aplicativo mobile Flutter para acompanhar evolução física e esportiva com disciplina, clareza e gamificação sóbria.

> “Os limites só existem se você os deixar existir.”

## Estado atual

A aplicação inicia sem registros fictícios: zero treinos, atividades, amigos, conquistas e pontuação. O onboarding inclui a escolha de modalidades primária, secundária e terciária para o Ranking. O PostgreSQL local já possui o esquema inicial, mas a API autenticada que conectará o Flutter a ele ainda está em desenvolvimento.

## Requisitos

- Flutter 3.44.4 (stable) ou compatível
- Dart 3.12.2 ou compatível
- Android Studio/SDK para Android
- Xcode em macOS para iOS

## Executar

```bash
flutter pub get
flutter run
```

Qualidade:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

O último comando depende de um toolchain Android funcional. Na criação desta fase, a compilação Gradle não concluiu dentro de 5 minutos e deverá ser revalidada em um ambiente Android configurado.

## Arquitetura

O código usa organização feature-first com separação proporcional entre apresentação, domínio e dados. Riverpod fornece injeção de dependência e estado; GoRouter mantém rotas declarativas; `shared_preferences` persiste apenas a conclusão do onboarding. Contratos separam widgets dos futuros backends.

```text
lib/
  app/                 tema, aplicação e rotas
  core/widgets/        componentes e painters reutilizáveis
  features/            onboarding, dashboard, ranking, social e perfil
  shared/models/       modelos compartilhados
  shared/repositories/ contratos, mocks e providers
test/                  domínio, fluxo e regressão visual
```

Detalhes: [arquitetura](docs/architecture.md), [estrutura do código](docs/code-structure.md), [regras de domínio](docs/domain-rules.md), [sistema de ranking](docs/ranking-system.md) e [backlog](docs/BACKLOG.md).

## Dependências adicionadas

- `go_router`: navegação declarativa.
- `flutter_riverpod`: injeção de dependência e estado previsível.
- `shared_preferences`: persistência local mínima do onboarding.

`flutter pub add` baixou essas dependências e suas dependências transitivas. Nenhum SDK externo, backend, chave ou segredo foi adicionado.

## Limitações atuais

- Dados, ranking global, amigos, conquistas e histórico são demonstrativos.
- Perguntas de saúde, histórico familiar, termos e níveis são provisórios.
- Com menos de três categorias, o ranking retorna resultado provisório sem pontuação oficial.
- Edição de treinos, atividades, chat, scanner QR e notificações reais estão planejados.
- Os gráficos mostram valores normalizados simulados, não diagnóstico fisiológico.
- Build iOS requer macOS; build Android ainda precisa de revalidação do Gradle local.
