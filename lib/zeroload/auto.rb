module Kernel
  def zeroload!(directory=nil, *args)
    directory ||= caller_locations.first.absolute_path.sub(/\.[^.]*\z/, "")

    Zeroload.module(self, directory, *args)
  end
end
