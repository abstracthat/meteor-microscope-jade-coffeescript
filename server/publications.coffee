Meteor.publish 'posts', ->
  Posts.find()

Meteor.publish 'comments', (postId) ->
  Comments.find {postId}

Meteor.publish 'notifications', ->
  Notifications.find userId: @userId
