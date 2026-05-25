defmodule RewardsService.Rewards.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @valid_types ~w(earn redeem)
  @valid_reasons ~w(purchase referral signup promotion manual redemption)

  schema "transactions" do
    field :type, :string
    field :points, :integer
    field :reason, :string
    field :metadata, :map, default: %{}
    field :status, :string, default: "completed"

    belongs_to :user, RewardsService.Accounts.User, type: :binary_id

    timestamps()
  end

  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:user_id, :type, :points, :reason, :metadata])
    |> validate_required([:user_id, :type, :points, :reason])
    |> validate_inclusion(:type, @valid_types)
    |> validate_inclusion(:reason, @valid_reasons)
    |> validate_number(:points, greater_than: 0)
  end
end
