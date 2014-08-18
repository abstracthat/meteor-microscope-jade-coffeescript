@Posts = new Meteor.Collection 'posts'

Meteor.methods
  post: (postAttributes) ->
    user = Meteor.user()
    postWithSameLink = Posts.findOne
      url: postAttributes.url

    # Ensure user is logged in
    unless user
      throw new Meteor.Error 401, 'You need to login to post new stories'

    # Ensure the post has a title
    unless postAttributes.title
      throw new Meteor.Error 422, 'Please fill in a headline'
    
    # check that there are no previous posts with the same link
    if postAttributes.url and postWithSameLink
      throw new Meteor.Error 302, 'This link has already been posted', postWithSameLink._id

    # pick out the whitelisted keys
    post = _.extend _.pick(postAttributes, 'url', 'title', 'message'),
      title: postAttributes.title + (if @isSimulation then '(client)' else '(server)')
      userId: user._id
      author: user.username
      submitted: new Date().getTime()

    unless @isSimulation
      Future = Npm.require 'fibers/future'
      future = new Future()
      Meteor.setTimeout (-> future.return()), 5 * 1000
      future.wait()

    # Return the post's ID
    postId = Posts.insert post
