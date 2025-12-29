# Reactive Submodules

Reactive Submodules are meant to be used with [ReactiveTags](https://github.com/bajsucks/ReactiveTags)

All Reactive Submodules must adhere to the following structure:

module.Tags = {

    ["Tag"] = module.TagFunction

}

ReactiveTags will then call that TagFunction for every instance that has the tag "Tag". The function will be provided the instance that had the tag.

Submit your own Reactive Submodules and I'll add them I think