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
