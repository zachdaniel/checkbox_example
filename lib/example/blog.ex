defmodule Example.Blog do
  use Ash.Domain

  resources do
    resource Example.Blog.Post
  end
end
