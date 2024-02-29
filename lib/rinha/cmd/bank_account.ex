defmodule BankAccount do
  alias Rinha.Customer
  alias Rinha.InputTransaction

  defstruct [:valor, :descricao, :tipo, :customer_id]

  defmodule Event do
    @derive Jason.Encoder
    defstruct [:valor, :descricao, :tipo, :customer_id]
  end

  # Public command API

  def execute(%BankAccount{}, %InputTransaction{} = cmd) do
    %Event{
      valor: cmd.valor,
      descricao: cmd.descricao,
      tipo: cmd.tipo,
      customer_id: cmd.customer_id
    }
  end

  # State mutators

  def apply(%BankAccount{} = account, %Event{} = event) do
    %BankAccount{
      account
      | valor: event.valor,
        descricao: event.descricao,
        tipo: event.tipo,
        customer_id: event.customer_id
    }
  end
end
