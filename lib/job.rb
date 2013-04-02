# Wrapper around the new Resque Worker class API. It's similar to what we have in Minefold web and worked quite nicely there.
class Job

  def self.perform(*args)
    new(*args).work
  end

end
