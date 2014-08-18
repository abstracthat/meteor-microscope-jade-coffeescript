@Posts = new Meteor.Collection 'posts'

Posts.allow
  update: ownsDocument
  remove: ownsDocument

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
      userId: user._id
      author: user.username
      submitted: new Date().getTime()

    # Return the post's ID
    postId = Posts.insert post
