//
//  CircleAPI.swift
//  Charging
//
//  Created by chenzhibin on 15/9/19.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

import Foundation

class CircleAPI {
    
    //获取文章列表
    static let articlesNumberPerPage = 10
    static func getArticleList(page: Int, pageSize: Int, type: DCArticleListType, userId: String?, stationId: String?, completion: (success: Bool, articles: [DCArticle]?, errorMessage: String?) -> Void) -> NSURLSessionDataTask {
        
        var parameters: [String: AnyObject] = [
            "page": page,
            "pageSize": pageSize,
            "type": type.rawValue
        ]
        parameters["userId"] = userId
        parameters["stationId"] = stationId
        
        return DCHTTPSessionManager.shareManager().GET("api/social/article/list", parameters: parameters, completion: { (task, success, response, error) -> Void in
            if success && response.isSuccess() {
                var articles: [DCArticle] = []
                if let array = response.result.arrayObject() {
                    for dict in array {
                        if let dict = dict as? [String: AnyObject] {
                            let article = DCArticle(dict: dict)
                            articles.append(article)
                        }
                    }
                }
                completion(success: true, articles: articles, errorMessage: nil)
            }
            else {
                let errorMessage = DCWebResponse.errorMessage(error, withResponse: response)
                completion(success: false, articles: nil, errorMessage: errorMessage)
            }
        })
    }
    
    //获取文章详情
    static func getArticleInfo(articleId: String, userId: String?, completion: (responseCode: Int32, success: Bool, article: DCArticle?, errorMessage: String?) -> Void) -> NSURLSessionDataTask {
        var paramters = [
            "articleId": articleId
        ]
        paramters["userId"] = userId
        
        return DCHTTPSessionManager.shareManager().GET("api/social/article/info", parameters: paramters, completion: { (task, success, response, error) -> Void in
            if success && response.isSuccess() {
                guard let dict = response.result as? [String: AnyObject] else {
                    completion(responseCode: response.code, success: false, article: nil, errorMessage: HSSYDefaultRequestFailMessage)
                    return
                }
                let article = DCArticle(dict: dict)
                
                completion(responseCode: response.code, success: true, article: article, errorMessage: nil)
            }
            else {
                let errorMessage = DCWebResponse.errorMessage(error, withResponse: response)
                completion(responseCode: response.code, success: false, article: nil, errorMessage: errorMessage)
            }
        })
    }
    
    //获取回复列表
    static func getCommentList(articleId: String, page: Int, pageSize: Int, completion: (success: Bool, articleComments: [DCArticleComment]?, errorMessage: String?) -> Void) -> NSURLSessionDataTask {
        let paramters: [String: AnyObject] = [
            "articleId": articleId,
            "page": page,
            "pageSize": pageSize
        ]
        
        return DCHTTPSessionManager.shareManager().GET("api/social/comment/list", parameters: paramters, completion: { (task, success, response, error) -> Void in
            if success && response.isSuccess() {
                var articleComments: [DCArticleComment] = []
                if let array = response.result.arrayObject() {
                    for dict in array {
                        if let dict = dict as? [String: AnyObject] {
                            let articleComment = DCArticleComment(dict: dict)
                            articleComments.append(articleComment)
                        }
                    }
                }
                completion(success: true, articleComments: articleComments, errorMessage: nil)
            }
            else {
                let errorMessage = DCWebResponse.errorMessage(error, withResponse: response)
                completion(success: false, articleComments: nil, errorMessage: errorMessage)
            }
        })
    }
    
    //获取点赞列表
    static func getArticleLikeList(articleId: String, page: Int, pageSize: Int, completion: (success: Bool, articleLikes: [DCArticleLike]?, errorMessage: String?) -> Void) -> NSURLSessionDataTask {
        let paramters: [String: AnyObject] = [
            "articleId": articleId,
            "page": page,
            "pageSize": pageSize
        ]
        
        return DCHTTPSessionManager.shareManager().GET("api/social/like/list", parameters: paramters, completion: { (task, success, response, error) -> Void in
            if success && response.isSuccess() {
                var articleLikes: [DCArticleLike] = []
                if let array = response.result.arrayObject() {
                    for dict in array {
                        if let dict = dict as? [String: AnyObject] {
                            let articleLike = DCArticleLike(dict: dict)
                            articleLikes.append(articleLike)
                        }
                    }
                }
                completion(success: true, articleLikes: articleLikes, errorMessage: nil)
            }
            else {
                let errorMessage = DCWebResponse.errorMessage(error, withResponse: response)
                completion(success: false, articleLikes: nil, errorMessage: errorMessage)
            }
        })
    }
    
    //发表话题
    static func postArticleTopic(text: String, userId: String ,images: [UIImage], cityId: String?, completion: (success: Bool, errorMessage: String?) -> Void) -> NSURLSessionDataTask {
        return DCHTTPSessionManager.uploadImageManager().POST("api/social/topic", parameters: nil,
            constructingBodyWithBlock: { (formData: AFMultipartFormData!) -> Void in
                
                formData.appendPartWithFormData(userId.dataUsingEncoding(NSUTF8StringEncoding), name: "userId")
                
                formData.appendPartWithFormData(text.dataUsingEncoding(NSUTF8StringEncoding), name: "content")

                if (cityId != nil) {
                    formData.appendPartWithFormData(cityId?.dataUsingEncoding(NSUTF8StringEncoding), name: "cityId")
                }
                
                for (index, image) in images.enumerate() {
                    let imageData = UIImageJPEGRepresentation(image, 1)
                    formData.appendPartWithFileData(imageData, name: "images", fileName: "img\(index).jpg", mimeType: "image/jpeg")
                }

            },
            success: { (task, data) -> Void in
                print("response: api/social/topic success")
                let response = DCWebResponse(data: data)
                if response.isSuccess() {
                    completion(success: true, errorMessage: nil)
                } else {
                    completion(success: false, errorMessage: DCWebResponse.errorMessage(nil, withResponse: response))
                }
            },
            failure: { (task, error) -> Void in
                print("request: api/social/topic faulure")
                completion(success: false, errorMessage: DCWebResponse.errorMessage(error, withResponse: nil))
        })
    }
    
    //点赞
    static func likeArticle(articleId: String, like: Bool, userId: String, completion: (success: Bool, errorMessage: String?) -> Void) -> NSURLSessionDataTask {
        let parameters = [
            "articleId": articleId,
            "userId": userId,
            "like": like ? 1 : 0
        ]
        return DCHTTPSessionManager.shareManager().POST("api/social/like", parameters: parameters, completion: { (task, success, response, error) -> Void in
            if success && response.isSuccess() {
                completion(success: true, errorMessage: nil)
            }
            else {
                let errorMessage = DCWebResponse.errorMessage(error, withResponse: response)
                completion(success: false, errorMessage: errorMessage)
            }
        })
    }
    
    //评论/回复评论
    static func commentArticle(replyArticleId: String?, content: String, userId: String, replyCommentId: String?, completion: (success: Bool, errorMessage: String?) -> Void) -> NSURLSessionDataTask {
        var parameters = [
            "userId": userId,
            "content": content
        ]
        parameters["replyArticleId"] = replyArticleId
        parameters["replyCommentId"] = replyCommentId
        return DCHTTPSessionManager.shareManager().POST("api/social/comment", parameters: parameters, completion: { (task, success, response, error) -> Void in
            if success && response.isSuccess() {
                completion(success: true, errorMessage: nil)
            }
            else {
                let errorMessage = DCWebResponse.errorMessage(error, withResponse: response)
                completion(success: false, errorMessage: errorMessage)
            }
        })
    }
    
//    static func getMyEvaluateArticles(page: Int, userId: String, completion: (success: Bool, articles: [DCArticle]?, errorMessage: String?) -> Void) -> NSURLSessionDataTask {
//        return DCHTTPSessionManager.shareManager().GET("moment/my_moments/\(userId)/\(page)", parameters: nil, completion: { (task, success, response, error) -> Void in
//            if success && response.isSuccess() {
//                var articles: [DCArticle] = []
//                if let array = response.result.arrayObject() {
//                    for dict in array {
//                        if let dict = dict as? [String: AnyObject] {
//                            let article = DCArticle(dict: dict)
//                            articles.append(article)
//                        }
//                    }
//                }
//                completion(success: true, articles: articles, errorMessage: nil)
//            }
//            else {
//                let errorMessage = DCWebResponse.errorMessage(error, withResponse: response)
//                completion(success: false, articles: nil, errorMessage: errorMessage)
//            }
//        })
//    }
    
//    static func getPileEvaluateArticles(page: Int, stationId: String, completion: (success: Bool, articles: [DCArticle]?, errorMessage: String?) -> Void) -> NSURLSessionDataTask {
//        return DCHTTPSessionManager.shareManager().GET("moment/pile_moments/\(stationId)/\(page)", parameters: nil, completion: { (task, success, response, error) -> Void in
//            if success && response.isSuccess() {
//                var articles: [DCArticle] = []
//                if let array = response.result.arrayObject() {
//                    for dict in array {
//                        if let dict = dict as? [String: AnyObject] {
//                            let article = DCArticle(dict: dict)
//                            articles.append(article)
//                        }
//                    }
//                }
//                completion(success: true, articles: articles, errorMessage: nil)
//            }
//            else {
//                let errorMessage = DCWebResponse.errorMessage(error, withResponse: response)
//                completion(success: false, articles: nil, errorMessage: errorMessage)
//            }
//        })
//    }
    
    //删除文章
    static func deleteArticle(articleId: String, userId: String, completion: (success: Bool, errorMessage: String?) -> Void) -> NSURLSessionDataTask {
        let parameters = [
            "articleId": articleId,
            "userId": userId
        ]
        return DCHTTPSessionManager.shareManager().POST("api/social/article/delete", parameters: parameters, completion: { (task, success, response, error) -> Void in
            if success && response.isSuccess() {
                completion(success: true, errorMessage: nil)
            }
            else {
                let errorMessage = DCWebResponse.errorMessage(error, withResponse: response)
                completion(success: false, errorMessage: errorMessage)
            }
        })
    }
    
    
    //删除评论
    static func postForDeleteMyComment(userid: String, commentId: String, completion: (success: Bool, errorMessage: String?) -> Void) ->NSURLSessionDataTask {
        let parameters = [
            "commentId": commentId,
            "userId": userid
        ]
            return DCHTTPSessionManager.shareManager().POST("api/social/comment/delete", parameters: parameters, completion: { (task, success, response, error) -> Void in
            if success && response.isSuccess() {
                completion(success: true, errorMessage: nil)
            }
            else {
                let errorMessage = DCWebResponse.errorMessage(error, withResponse: response)
                completion(success: false, errorMessage: errorMessage)
            }
        })
    }
    
    //获取桩群分数
    static func getPileScores(stationId: String, completion: (success: Bool, scores: (commentAvgScore: Double, envirAvgScore: Double, devAvgScore: Double, cspeedAvgScore: Double)?, errorMessage: String?) -> Void) -> NSURLSessionDataTask {
        let parameters = [
            "stationId": stationId
        ]
        return DCHTTPSessionManager.shareManager().GET("api/social/station/score", parameters: parameters, completion: { (task, success, response, error) -> Void in
            if success && response.isSuccess() {
                guard let dict = response.result as? [String: AnyObject],
                    let commentAvgScore = dict["commentAvgScore"] as? Double,
                    let envirAvgScore = dict["envirAvgScore"] as? Double,
                    let devAvgScore = dict["devAvgScore"] as? Double,
                    let cspeedAvgScore = dict["cspeedAvgScore"] as? Double else {
                        completion(success: false, scores: nil, errorMessage: HSSYDefaultRequestFailMessage)
                        return
                }
                completion(success: true, scores: (commentAvgScore, envirAvgScore, devAvgScore, cspeedAvgScore), errorMessage: nil)
            }
            else {
                let errorMessage = DCWebResponse.errorMessage(error, withResponse: response)
                completion(success: false, scores: nil, errorMessage: errorMessage)
            }
        })
    }
}
