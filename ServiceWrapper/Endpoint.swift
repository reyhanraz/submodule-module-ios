//
//  Config.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 04/03/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

import L10n_swift

struct Endpoint{
    static let login = "accounts/login"
    static let register = "accounts/register"
    
    //Get My Profile
    static let profile = "api/v1/profile"
    static let findUser = "api/v1/users/find"

    static let challenges = "api/challenges"
    static let validateChallenge = "api/challenges/validate"
    
    static let forgotPassword = "api/accounts/forgot-password"
    static let resetPassword = "api/accounts/reset-password"
    
    //Address
    static let getAddressList = "\("config.path".l10n())Addresses"
    static let addressDetails = "\("config.path".l10n())Address"
    static let updateLocation = "updateArtisanGeoLocation"
    static let searchLocation = "locationAreaList"
    static let getProvinceList = "locationProvinceList"
    
    //Artisan
    static let getDetailArtisan = "artisanProfile"
    static let getListArtisan = "findArtisanList"
    static let getFavoriteListArtisan = "artisanFavoriteList"
    static let getNearbyArtisan = "findArtisanNearby"
    
    //Rating
    static let giveRating = "artisanReview"
    static let getRatingList = "artisanReviewList"
    
    //Category
    static let getCategories = "serviceCategoryList"
    static let getCategoryTypes = "serviceCategoryTypeList"
    
    //Favorite
    static let addFavorite = "artisanFavoriteSet"
    static let removeFavorite = "artisanFavoriteRemove"
    
    //Upload
    static let getSignedURL = "uploadSignedUrl"
    
    //Service List
    static let artisanServicesList = "artisanServiceList"
    static let artisanServicesDetail = "artisanService"
    
    static let changePassword = "\("config.path".l10n())ChangePassword"
    
    //EventTracking
    static let eventLog = "\("config.path".l10n())EventLog"
    
    static let artisanGalleries = "artisanGalleryItems"
    static let pathGalleries = "\("config.path".l10n())GalleryItems"
    
    static let newsList = "newsList"
    static let newsDetail = "news"
    
    //Notification
    static let registerNotification = "\("config.path".l10n())PushToken"
    static let notificationMessages = "\("config.path".l10n())NotificationMessages"
    static let notificationUnreadCount = "\("config.path".l10n())NotificationUnreadCount"
    
    //Payment
    static let customRequestPaymentInit = "customRequestPaymentInit"
    static let bookingPayment = "bookingPayment"
    static let bookingPaymentRefundInit = "bookingPaymentRefundInit"
    static let initPayout = "initPayout"
    static let balanceSummary = "\("config.path".l10n())PaymentBalance"
    static let bookingPaymentSummaryHistories = "bookingPaymentSummaryHistories"
    static let bookingPaymentSummaryHistory = "bookingPaymentSummaryHistory"
    
    static let artisanCalendar = "artisanCalendar"
    
}
