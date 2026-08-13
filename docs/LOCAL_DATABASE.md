# Banco PostgreSQL local

O banco local `limitbreaker` usa o PostgreSQL instalado na máquina para desenvolvimento. A primeira migração fica em `database/migrations/202608100001_initial_local_schema.sql`.

## Tabelas

- `app_profiles`: dados básicos do perfil.
- `health_assessments`: perfil de treino, nível de atividade, consentimento e indicação de treino adaptado.
- `health_disclosures`: respostas pessoais e histórico familiar, incluindo a descrição fornecida pela pessoa.
- `workout_suggestions`: sugestão gerada para o perfil, modalidade e grupo muscular escolhidos.

## Segurança

- O APK Flutter não recebe senha, string de conexão PostgreSQL, nem credenciais administrativas.
- A próxima etapa é uma API local autenticada, responsável por validar identidade e gravar apenas os dados do perfil autenticado.
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

Use `http://127.0.0.1:8080/health` para verificar a integração PostgreSQL. A API inicial expõe somente verificação e leitura de perfil; gravação e vínculo por usuário dependem da autenticação real.
