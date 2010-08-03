module Github
  class Repo < Struct.new(:name, :fork)

    alias :fork? :fork
  end
end
