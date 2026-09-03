# Banco PostgreSQL local

O banco local `limitbreaker` usa o PostgreSQL instalado na máquina para desenvolvimento. A primeira migração fica em `database/migrations/202608100001_initial_local_schema.sql`.

## Tabelas

- `app_profiles`: dados básicos do perfil.
- `health_assessments`: perfil de treino, nível de atividade, consentimento e indicação de treino adaptado.
- `health_disclosures`: respostas pessoais e histórico familiar, incluindo a descrição fornecida pela pessoa.
- `workout_suggestions`: sugestão gerada para o perfil, modalidade e grupo muscular escolhidos.
- `users` e `local_sessions`: contas com nome de usuário, hash bcrypt e vínculo opcional ao perfil físico; sessões locais mantêm apenas o hash do token.
- `workout_sessions`, `workout_exercises` e `workout_sets`: lançamentos de treino, exercícios, séries, repetições e cargas.
- `exercise_categories` e `exercises`: catálogo de categorias musculares e exercícios de academia. `exercises.exercise_category_id` referencia `exercise_categories.id`.

## Segurança

- O APK Flutter não recebe senha, string de conexão PostgreSQL, nem credenciais administrativas.
- A API local autenticada em `server/` valida a identidade e grava apenas os dados do perfil autenticado. A próxima ampliação é persistir onboarding e sugestões de treino pela mesma fronteira.
- A migração local é separada da migração Supabase em `supabase/migrations/`, pois a segunda depende de `auth.users` e RLS do Supabase.
- Não registre respostas de saúde em logs, analytics ou mensagens de erro.

## Aplicar migrações

Com uma sessão administrativa do PostgreSQL:

```powershell
& 'C:\Program Files\PostgreSQL\18\bin\psql.exe' -U postgres -d limitbreaker -v ON_ERROR_STOP=1 -f database\migrations\202608100001_initial_local_schema.sql
```

Não inclua a senha no comando, em arquivos versionados ou no aplicativo.

## API local de desenvolvimento

A ponte fica em `server/` e é o único componente que pode receber `DATABASE_URL`. O Flutter não recebe essa variável.

```powershell
Set-Location server
dart pub get
$env:DATABASE_URL='postgresql://USUARIO:SENHA@127.0.0.1:5432/limitbreaker'
dart run bin/server.dart
```

Use `http://127.0.0.1:8080/health` para verificar a integração PostgreSQL. A API local expõe cadastro, login, perfil autenticado e criação/listagem de treinos. Os endpoints de treino exigem `Authorization: Bearer <token>` e gravam somente no perfil da sessão autenticada.

Para rodar no Windows ou navegador, o Flutter usa `http://127.0.0.1:8080` por padrão. Em emulador Android, use:

```powershell
flutter run --dart-define=LOCAL_API_BASE_URL=http://10.0.2.2:8080
```
