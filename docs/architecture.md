# Arquitetura

## Direção

O aplicativo é 100% Flutter/Dart, mobile-first e preparado para Android e iOS. A arquitetura é feature-first, com separação suficiente para substituir mocks por integrações reais sem transformar a primeira fase em uma Clean Architecture burocrática.

## Camadas

- `presentation`: telas, widgets, navegação e estados visuais.
- `domain`: regras puras, como o cálculo de Ranking.
- `data/application`: contratos, implementações locais/mock e providers Riverpod.
- `core/shared`: design system, componentes reutilizáveis e modelos transversais.

## Dependências e fluxo

Os widgets consomem providers Riverpod. Providers expõem contratos de repositório, hoje implementados por `MockAppRepository` ou `LocalOnboardingRepository`. A apresentação não conhece banco, API ou detalhes de armazenamento.

GoRouter declara o fluxo `/` → `/welcome` ou `/home`; as rotas principais usam uma navegação inferior com Início, Ranking, Amigos, Conquistas e Perfil. Não existe barra lateral.

## Design system

O sistema visual fica em `app/theme/app_theme.dart` e centraliza cores, espaçamento, tipografia, cards, inputs e botões. A paleta usa preto-vazio, carbono, grafite, aço, branco-osso e um acento frio discreto. A assinatura visual é uma fratura angular e uma silhueta abstrata desenhadas com `CustomPainter`, evitando dependência de assets externos.

## Evolução planejada

- Separar repositórios mock por feature quando cada módulo ganhar regras próprias.
- Adicionar estados tipados de aplicação para edição de treinos e atividades.
- Definir backend e autenticação somente após decisão técnica explícita.
- Manter saúde isolada, sem logs de respostas sensíveis e sem analytics desses campos.
