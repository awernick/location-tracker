[
  [NSIndexPath, NSIndexPathWrap]
].each do |base, wrapper|
    base.send(:include, wrapper)
end
