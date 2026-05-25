defmodule RewardsService.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "users" do
    field :email, :string
    field :name, :string
    field :api_key_hash, :string
    field :api_key, :string, virtual: true

    has_one :wallet, RewardsService.Wallet.Wallet
    has_many :transactions, RewardsService.Rewards.Transaction

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :name])
    |> validate_required([:email, :name])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> put_api_key()
  end

  defp put_api_key(changeset) do
    key = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
    hash = :crypto.hash(:sha256, key) |> Base.encode16(case: :lower)

    changeset
    |> put_change(:api_key, key)
    |> put_change(:api_key_hash, hash)
  end
end
