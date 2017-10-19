//
//  Api.swift
//  GymMe
//
//  Created by Eno Reyes on 7/3/17.
//  Copyright © 2017 Eno Reyes. All rights reserved.
//

import Foundation

struct Api {
    static var User = UserApi()
    static var Post = PostApi()
    static var Comment = CommentApi()
    static var PostComment = PostCommentApi()
    static var MyPosts = MyPostsApi()
    static var Follow = FollowApi()
    static var Feed = FeedApi()
    static var Hashtag = HashtagApi()
    static var Notification = NotificationApi()
}
