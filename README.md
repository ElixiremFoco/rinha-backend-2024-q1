# Rinha Backend 2024 Q1 - Elixir

[![ci](https://github.com/elixiremfoco/rinha-backend-2024-q1/actions/workflows/ci.yml/badge.svg)](https://github.com/elixiremfoco/rinha-backend-2024-q1/actions/workflows/ci.yml)
[![load-test](https://github.com/elixiremfoco/rinha-backend-2024-q1/actions/workflows/load_test.yml/badge.svg)](https://github.com/elixiremfoco/rinha-backend-2024-q1/actions/workflows/load_test.yml)

Nossa solução para a Rinha de Backend V2, organizada pelo [@zanfranceschi](github.com/zanfranceschi).

Mais detalhes sobre o desafio podem ser encontrados na [descrição oficial](https://github.com/zanfranceschi/rinha-de-backend-2024-q1) do projeto.

## Propósito

A ideia deste projeto e desta versão tem o foco em apresentar mais detalhes sobre a linguagem de progrmamação [Elixir](elixir-lang.org), além de apresentar soluções robustas para um desenvolvimento que usa programação funcional e distribuída.

Com isso, queremos democratizar o conteúdo de criação de aplicações distribuídas, usando Elixir, para o público, além de de participar do desafio com uma stack já bem conhecida para solucionar o problema proposto desde o uso do Erlang na década de 80 até os dias atuais, por exemplo, pelo Whatsapp.

## Ambiente de Desenvolvimento

Usamos `docker` e/ou `nix` para desenvolver localmente.

### Docker

Basta executar `docker compose up -d` e você terá o projeto rodando em ambiente de "prod".

_TODO_: ambiente de dev

### Nix

Para executar o ambiente de `dev` com `nix`, basta executar o comando `nix develop` na raiz do projeto ou, caso use o `direnv`: `direnv allow`.

Dessa forma será instalado os pacotes de elixir, nginx e postgresql para desenvolvimento local.

### Comandos gerais

Para baixar dependências:

```sh
mix deps.get
```

Para configurar o banco de dados bem como as seeds:

```shell
mix ecto.setup
```

Para levantar o servidor web (apenas de uma instância):

```sh
mix phx.server
```

Caso queria um REPL junto ao servidor, basta executar: `iex -S mix phx.server`

---

Espero que gostem!
