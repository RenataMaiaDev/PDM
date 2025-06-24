
# Spotify Clone

Este projeto é um clone simplificado do Spotify, desenvolvido em Flutter para Android, utilizando SQLite como banco de dados local para persistência de dados. O objetivo é simular as principais funcionalidades de um aplicativo de streaming de música, incluindo gerenciamento de perfil, listagem de músicas e artistas, e uma base para playlists.

## Funcionalidades

- **Autenticação de Usuário:**
    - **Cadastro:** Crie novas contas de usuário com nome, e-mail, senha e uma foto de perfil.
    - **Login:** Acesse o aplicativo com suas credenciais registradas.
    - **Logout:** Encerre sua sessão, limpando o estado de login no dispositivo.
- **Gerenciamento de Perfil:**
    - Visualize e edite seu nome, e-mail e foto de perfil.
- **Página Inicial (Home):**
    - Exibe seções de Músicas Recentes, Músicas Mais Tocadas e Artistas Favoritos.
- **Playlists:**
    - Gerencie suas playlists de músicas (funcionalidade básica).
- **Navegação:**
    - Menu lateral (Drawer) com opções de perfil e logout.
    - Barra de navegação inferior `BottomNavigationBar` para transição rápida entre as principais seções (Home, Playlists, Perfil).

## Tecnologias Utilizadas

- **Flutter:** Framework de UI para construção de aplicações nativas.
- **Dart:** Linguagem de programação.
- **SQLite:** Banco de dados relacional embarcado, usado para armazenamento local de dados.
- `sqflite`: Plugin Flutter para interagir com o SQLite.
- `image_picker`: Para selecionar imagens da galeria ou câmera.
- `camera`: Para funcionalidades de câmera (tirar fotos).

##  Configuração e Instalação

- **Flutter SDK:** Certifique-se de ter o Flutter SDK instalado e configurado.
- **Android Studio / VS Code:** Com os plugins Flutter/Dart instalados.
- Um emulador Android ou um dispositivo físico conectado.

### Passos para Rodar o Projeto 

Clone o Repositório

```bash
 git clone https://github.com/RenataMaiaDev/PDM.git
```

Instale as Dependências

```bash
 flutter pub get
```

Verifique a Configuração do Flutter

```bash
 flutter doctor
```

Execute o Aplicativo

```bash
 flutter run
```

## Próximos Passos e Melhorias Futuras

Este projeto serve como uma base para um clone do Spotify. Há várias melhorias e funcionalidades que podem ser implementadas para expandir suas capacidades:

- **Reprodução de Áudio Avançada:** Integração com um player de áudio mais robusto (ex: just_audio) para controle total de reprodução, pause, volume, progresso e fila de músicas.
- **Busca de Conteúdo:** Implementar uma funcionalidade de busca para músicas, artistas e playlists.
- **Funcionalidades de Playlist:** Adicionar, remover e reordenar músicas em uma playlists.
- **Segurança da Senha:** Implementar hashing de senhas (ex: usando bcrypt) para armazenar senhas de forma segura no banco de dados, protegendo os dados do usuário.
- **Testes:** Adicionar testes unitários para a camada de repositórios e testes de widget para os componentes da UI, garantindo a robustez do aplicativo.
- **Sincronização com API Externa:** Conectar a um serviço de streaming real (Spotify API) para obter dados de músicas e artistas dinamicamente.