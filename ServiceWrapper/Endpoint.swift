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
    static let profil = "api/v1/profile"
    static let findUser = "api/v1/users/find"
    static let metadata = "api/v1/profile/metadata"
    static let resendEmailVerification = "api/v1/profile/resend-verification"

    static let challenges = "api/challenges"
    static let validateChallenge = "api/challenges/validate"
    
    static let forgotPassword = "api/accounts/forgot-password"
    static let resetPassword = "api/accounts/reset-password"
    
    //Address
    static let getAddressList = "\("config.path".l10n())Addresses"
    static let addressDetails = "api/v1/profile/address"
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
    static let getCategories = "api/v1/categories"
    static let getCategoryTypes = "serviceCategoryTypeList"
    
    //Favorite
    static let addFavorite = "artisanFavoriteSet"
    static let removeFavorite = "artisanFavoriteRemove"
    
    //Upload
    static let getSignedURL = "uploadSignedUrl"
    static let createMedia = "api/v1/media/image"
    static let confirmUpload = "api/v1/media/confirm"
    static let confirmArrayUpload = "api/v1/media/confirms"

    
    //Service List
    static let artisanServices = "api/v1/services"
    
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
