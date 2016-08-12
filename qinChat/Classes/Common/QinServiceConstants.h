/*!
 @header QinServiceConstants.h
 @abstract
 @author kinstalk.com
 @version 1.00 15/8/9
 Created by DengHua on 15/8/9.
 */




#undef    DEF_SINGLETON
#define DEF_SINGLETON(__class) \
+ (__class *)sharedInstance;

#undef    IMP_SINGLETON
#define IMP_SINGLETON(__class) \
+ (__class *)sharedInstance \
{ \
static dispatch_once_t once; \
static __class * __singleton__; \
dispatch_once( &once, ^{ __singleton__ = [[__class alloc] init]; } ); \
return __singleton__; \
}

#define SERVICE_DISPATCH_START    dispatch_async(serviceQueue, ^{

#define SERVICE_DISPATCH_END      });
//消息发送块定义
typedef void (^infoSendSuccessBlock)(NSDictionary *dic);

typedef void (^infoSendFailBlock)(NSDictionary *dic);


typedef enum MESSAGE_TO_TYPE {
    MESSAGE_TO_TYPE_GROUP_TYPE = 1, //群消息
    MESSAGE_TO_TYPE_P2P_TYPE = 2, //点对点消息
    MESSAGE_TO_TYPE_P2P_STEWARD = 3,//小管家消息
    MESSAGE_TO_TYPE_FRIEND = 5,//好友消息
    
} MESSAGE_TO_TYPE;

typedef enum ROUTING_KEY {
    CHAT_ROUTING_KEY = 1, //聊天
    QLOVE_ROUTING_KEY = 2,//qLove产品
    LIVE_ROUTING_KEY = 9,//直播
    
} ROUTING_KEY;


typedef enum LIVE_MESSAGE_TYPE {
    LIVE_MESSAGE_TEXT = 1, //文本
    LIVE_MESSAGE_ZAN = 2,//点赞
    LIVE_MESSAGE_LUCKY_GRAB = 3,//红包领取
    LIVE_MESSAGE_LUCKY_GRAB_NB = 4,//红包领取 手气最佳
    LIVE_MESSAGE_AUDIO = 5,//语音

} LIVE_MESSAGE_TYPE;

typedef enum LIVE_STATUS_TYPE {
    LIVE_STATUS_HEART = 0, //心跳
    LIVE_STATUS_STOP = 1,//暂停
    LIVE_STATUS_START = 2,//开始
    LIVE_STATUS_NET_ERROR = 3,//网络故障
    LIVE_STATUS_NET_RECOVER = 4,//网络恢复
    LIVE_STATUS_NET_END = 5,//直播结束
    LIVE_STATUS_AUDIO_OPEN = 6,//语音开关打开
    LIVE_STATUS_AUDIO_CLOSE = 7,//语音开关关闭

} LIVE_STATUS_TYPE;

typedef enum LIVE_STATUS_ENUM {
    LIVE_STATUS_PLAN = 1, //准备直播
    LIVE_STATUS_GOING = 2,//直播中
    LIVE_STATUS_TRANSCODING = 3,//转换码
    LIVE_STATUS_END = 4,//直播结束

} LIVE_STATUS_ENUM;

typedef enum USER_INVITE_TYPE {
    USER_INVITE_AGREE = 1, //同意
    USER_INVITE_IGNORE = 2,//忽略

} USER_INVITE_TYPE;

typedef enum UNREAD_TYPE {
    UNREAD_TYPE_NORMAL = 0,//未读数不变
    UNREAD_TYPE_PLUS = 1, //未读数+1
    UNREAD_TYPE_NOTIFY = 2,//通知未读消息
    UNREAD_TYPE_COMMENT = 3,//评论未读消息

} UNREAD_TYPE;

typedef enum COMMENT_NOTIFY_TYPE {
    NOTIFY_TYPE_DYNAMIC = 1,//评论你的动态
    NOTIFY_TYPE_REPLAY = 2, //回复了你
    NOTIFY_TYPE_POSTER = 3, //帖主发了评论
    NOTIFY_TYPE_AT = 4, //@

} COMMENT_NOTIFY_TYPE;

typedef enum COMMENT_TYPE {
    COMMENT_TYPE_GROUP = 0, //群内评论
    COMMENT_TYPE_WORLD = 1, //世界评论

} COMMENT_TYPE;

typedef enum MOMENT_TYPE {
    un_sync = 0, //不同步
    moment_sync = 1, //同步

} MOMENT_TYPE;

typedef enum COMMENT_CONTENT_TYPE {
    COMMENT_CONENT_TYPE_TEXT = 1,//文字
    COMMENT_CONENT_TYPE_IMG = 2, //图片
    COMMENT_CONENT_TYPE_EMOJI = 3,//表情
    COMMENT_CONENT_TYPE_VIDEO = 4,//声音

} COMMENT_CONTENT_TYPE;

typedef enum MY_GROUP_TYPE {
    NOT_FOUND_GROUP = 0,//未找到该群
    FOLLOW_GROUP = 1, //关注的群
    JOINED_GROUP = 2,//加入的群
} MY_GROUP_TYPE;

typedef enum SOCKET_STATUS {
    REQ_SUCCESS = 0, //成功
    REQ_UNDEFINED = 500,//未知错误
    REQ_NOT_FRIEND = 501,//非好友关系
    
} SOCKET_STATUS;

typedef enum RECENT_CONTACTS_BUSINESS_TYPE {
    BUSINESS_TYPE_MESSAGE = 1, //消息
    BUSINESS_TYPE_NOTIFY = 2,  //通知
    BUSINESS_TYPE_COMMENT = 3, //评论

} RECENT_CONTACTS_BUSINESS_TYPE;

//群设置类型
typedef enum {
    GROUPCONFIGTYPE_NODEF = 0, //未定义
    GROUPCONFIGTYPE_SWITCH_NICKNAME = 1, //是否显示群用户昵称
    GROUPCONFIGTYPE_MODIFY_AVATAR = 2,   //修改群封面  ,注意修改头像的时候，需要传GROUPAVATAR_TYPE ，要不然会报错
    GROUPCONFIGTYPE_MODIFY_MAX = 3,         //群大小
    GROUPCONFIGTYPE_MODIFY_NICKNAME = 4, //群用户昵称
    GROUPCONFIGTYPE_SWITCH_NODISTURB = 5,    //设置免打扰
    GROUPCONFIGTYPE_SWITCH_MAIN = 6,     //设置主群
    GROUPCONFIGTYPE_MODIFY_GROUPNAME = 7, //设置群名称
    GROUPCONFIGTYPE_MODIFY_GROUP_INTER_VERIFY = 8, //设置入群验证策略
    GROUPCONFIGTYPE_MODIFY_GROUP_USER_PUBLICBIRTHDAY = 9, //设置生日公开
    GROUPCONFIGTYPE_MODIFY_GROUP_USER_PUBLICMOBILE = 10, //设置手机号公开
    GROUPCONFIGTYPE_MODIFY_GROUP_MICROWINDOW_REMIND = 11, //设置微窗提醒
    GROUPCONFIGTYPE_MODIFY_GROUP_CHAT_REMIND = 12, //设置聊天提醒
    GROUPCONFIGTYPE_MODIFY_GROUP_USER_AVATER = 13, //设置群用户头像
    GROUPCONFIGTYPE_MODIFY_GROUP_INTRODUCE = 15,   //群简介
    GROUPCONFIGTYPE_SWITCH_PUBLICDISCUSS = 16,    //是否公开讨论
    GROUPCONFIGTYPE_UPDATE_TIME = 17,    //修改群更新时间
    GROUPCONFIGTYPE_UPDATE_TOP = 30,    //修改群排序
    GROUPCONFIGTYPE_UPDATE_COVER = 18,    //修改群封面
    GROUPCONFIGTYPE_UPDATE_APPLY = 19,    //修改是否允许申请入群
    GROUPCONFIGTYPE_UPDATE_LOCATION = 20,    //修改群位置信息
    GROUPCONFIGTYPE_UPDATE_NICKNAMEANDAVATAR = 21,    //修改群头像和昵称
    GROUPCONFIGTYPE_UPDATE_COMMENTNOTIFY =22, //评论提醒

} GROUP_CONFIG_MODIFY_TYPE;

//验证功能
typedef enum {
    GROUP_VERIFY_WAY_OFF = 0,   //关闭
    GROUP_VERIFY_WAY_MASTER = 1, //群主验证
    GROUP_VERIFY_WAY_ALL = 2,    //所有人验证
    
} GROUP_VERIFY_WAY;
//群用户邀请状态状态
/**
 * 0 未操作 1 通过 2 忽略 3 在群 4 拒绝
 */
typedef enum {
    GROUP_INVITE_INIT = 0,
    GROUP_INVITE_PASS = 1,
    GROUP_INVITE_IGNORE = 2,
    GROUP_INVITE_IN_GROUP = 3,
    GROUP_INVITE_REFUSE = 4,
    
} GROUP_INVITE_TYPE;
//群打扰
typedef enum {
    GROUP_disturbType_close = 0,             //关闭
    GROUP_disturbType_open = 1,            //打开
    
} GROUP_disturbType;

//群确认类型 0 未操作 1已确认 2已忽略
typedef enum {
    GROUP_CONFIRM_NONE = 0, //未操作
    GROUP_CONFIRM_OK,       //已经确认
    GROUP_CONFIRM_IGNORE,    //已经忽略
    
    GROUP_VERIFYTYPE = 4, //公开群
} GROUP_CONFIRM_TYPE;

//上传类型
typedef enum QinUserModelsAvatarType {
    QinUserModelsAvatarType_UNK = 0,      //未定义
    QinUserModelsAvatarType_cutsom = 1,   //自定义
    QinUserModelsAvatarType_sys,          //系统设置
} QinUserModelsAvatarType;

#define     NEW_MESSAGES_URL   @"/msg/v2/get"
#define     GROUP_FIND_GROUPS  @"/group/findGroups"
#define     GROUP_FIND_USERS  @"/group/findGroupUsers"
#define     FIND_USER_INVITES  @"/group/user/findUserInvites"
#define     GET_USER_INFOS  @"/user/batch/info"
#define     GROUP_MODIFY  @"/group/config"
#define     GROUP_EXTRA  @"/group/getGroupExtra"
#define     GROUP_INFO  @"/group/getGroupInfo"
#define     FEED_UNREAD  @"/feed/unread"
#define     GROUP_USER_MODIFY  @"/group/user/config"

#pragma mark 直播相关
#define     LIVE_INIT  @"/live/host/init"
#define     LIVE_START  @"/live/host/start"
#define     LIVE_END  @"/live/host/end"
#define     LIVE_ROOM_LIST  @"/live/room/list"
#define     LIVE_CHEST_LIST  @"/live/chest/list"
#define     LIVE_WATCH_START  @"/live/watch/start"
#define     LIVE_WATCH_END  @"/live/watch/end"
#define     LIVE_WATCH_DANMU  @"/live/watch/danmuku"
#define     LIVE_DELETE  @"/live/delete"
#define     LIVE_UPDATE_COVER  @"/live/host/updateCover"
#define     LIVE_VOICE_SWITCH  @"/live/host/switchVoiceMsg"

#pragma mark 好友相关
#define     FRIEND_ADD  @"/friend/add"
#define     FRIEND_ADD_BATCH  @"/friend/addBatch"
#define     FRIEND_ADD_MOBILE  @"/friend/add/mobile"
#define     FRIEND_INVITE_LIST  @"/friend/findUserInvites"
#define     FRIEND_CONFIRM  @"/friend/confirm"
#define     FRIEND_LIST  @"/friend/list"
#define     FRIEND_REMOVE  @"/friend/remove"

#pragma mark 评论相关
#define     COMMENT_LIST  @"/feed/comment/messages"

#define GROUPS_FEED_UNREAD_TIME @"groups_unread_time_"

#define WORLD_UNREADHASH        @"WorldUnreadHash"

#define     CRYPTO_KEY   @"sfe023f_9fd&fwfl"

#define  LOCAL_SEQ   900000000

#define intValueFromAnyObject(obj) ([obj respondsToSelector:@selector(intValue)]) ? [obj intValue] : 0;

#define MESSAGE_PULL_KEY     [NSString stringWithFormat:@"messageLastTimestamp_%@",uId] //消息拉取
#define GROUP_LIST_PULL_KEY  [NSString stringWithFormat:@"groupListLastTimestamp_%@",uId]  //群列表拉取
#define GROUP_USER_PULL_KEY  [NSString stringWithFormat:@"groupUserLastTimestamp_%@_%@",gId,uId]  //群用户拉取
#define USER_INVITE_PULL_KEY [NSString stringWithFormat:@"userInviteLastTimestamp_%@",uId] //用户邀请列表拉取
#define USER_AUDIT_PULL_KEY  [NSString stringWithFormat:@"userAuditLastTimestamp_%@",uId] //用户审核拉取
#define USER_FRIEND_PULL_KEY [NSString stringWithFormat:@"userFriendLastTimestamp_%@",uId] //用户好友拉取
#define COMMENT_LIST_PULL_KEY [NSString stringWithFormat:@"commentLastTimestamp_%@",uId] //用户评论拉取
#define NOTIFY_UNREAD_KEY [NSString stringWithFormat:@"notifyLastTimestamp_%@",uId] //用户评论拉取
#define COMMENT_LIST_TEMP_KEY [NSString stringWithFormat:@"commentLastTimestampTempKey_%@",uId] //用户评论拉取

#define QUEUE_CHECK  if (dispatch_get_specific(queueKey)){ \
 NSLog(@" 当前线程是: %@, 当前队列是: %@ 。", [NSThread currentThread], dispatch_get_current_queue()); \
                        block(); \
                        } \
                        else{ \
                        dispatch_async(serviceQueue, block); \
                        }


