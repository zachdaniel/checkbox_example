defmodule Example.Blog.Post do
  use Ash.Resource, otp_app: :example, domain: Example.Blog, data_layer: Ash.DataLayer.Ets

  actions do
    defaults [:read, :destroy, create: [:categories], update: [:categories]]
  end

  attributes do
    uuid_v7_primary_key :id
    attribute :categories, {:array, :string}
  end
end
