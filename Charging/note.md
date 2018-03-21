# 开发笔记

## 发布
- 推送配置 PushConfig.plist
APS_FOR_PRODUCTION
1.3.1版本新增，表示应用是否采用生产证书发布( Ad_Hoc 或 APP Store )，0 (默认值)表示采用的是开发者证书，1 表示采用生产证书发布应用。
APP_KEY
在管理Portal上创建应用时自动生成的（AppKey）用以标识该应用

- 服务器地址配置 SERVER_URL

## Bundle id
~~com.xpg.inhouse.Charging~~
com.hssy.ChargingPole

## Map key
1UxG9uMhjKEku1tsvyyoWAu9 (com.xpg.inhouse.Charging)
k3p2UtgibH039CmD9zWOlAAl (com.hssy.ChargingPole)

## JPush
- com.hssy.ChargingPole
AppKey:         bce02c9d6f8bf7c077d19bf3
Master Secret:  b2def656866c9f41f2b18d33

- com.xpg.inhouse.Charging
AppKey:         98e79b905a0f4c6072db9ae2
Master Secret:  6bc237c1f71985e9fac998d4

## TODO
- HSSYTime 

## API
- ERROR CODE
FAIL(-1,"处理失败"),
SUCCESS(0,"成功"),
REGISTER_FAIL(10000,"注册失败"),
LOGIN_FAIL(10001,"登录失败"),
ACCOUNT_EXISTED(10002,"账户已存在"),
AUTHORIZE_FAIL(20000,"授权失败"),
VALIDATION_CODE_ERROR(20001,"验证码错误或失效"),
INVALID_TOKEN(20002,"无效token"),
ERROR_CLIENTID(20003,"Token不是由本终端生成"),
INVALID_USERID(20004,"无效Userid"),
INVALID_RETOKEN(20005,"无效RefreshToken"),
INVALID_CLIENTID(20006,"无效clientId"),
TOKEN_EXPIRED(20007,"Token过期"),
ILLEGAL_DATA(30000,"非法参数"),
ERROR_DATA(30001,"错误参数"),
NO_AUTH(30002,"不能給自己授权"),
HAD_AUTH(30003,"不能重复授权"),
EMPTY_ACCOUNT(30004,"账户不存在"),
ILLEGAL_ACCOUNT_PASSWORD(30005,"用户名/密码错误"),
PERIOD_OCCUPIED(304006,"该时间范围已经有了订单不能再次下单"),
SYSTEM_ERROR(40000,"系统错误"),
SYSTEM_BUSY(40001,"系统繁忙"),
FAMILY_ACCOUNT(50001,"家人账户无需预约"),
INVALID_ORDER(60001,"无效订单号");

- 时间周的格式 (发布，预约) 
sun mon tue wed thu fri sat
 1   2   3   4   5   6   7


## 打企业包需要修改内容
修改BunbleID：com.xpg.inhouse.Charging
修改Provisioning 为公司的发布许可
修改Inhouse的PushConfig.plist 的 TargetMembership, 把Inhouse的添加到Target里面，并去除原来的“PushConfig.plist”
修改GlobalConstants.h中的友盟ChanelID为"X_Distribution"
以上四步已经可以用Enterprise的configuration来直接实现，如果打三优证书的包请使用“Appstore”的configuration

## 主要颜色
主色(绿色)：#00B4AE
辅色(蓝色)：#01ACF1
辅色(橙色)：#F8891D
辅色(红色)：#DB472C
辅色(字深灰)：#999999
辅色(底部按钮浅灰)：#F7F8F8
辅色(间隔线浅灰)：#EEEEEE

添加颜色方法：将“HSSY Color.clr”添加到 “~/Library/Colors” 下




## 清理类似功能的类
HSSYDatabaseCharge <==> HSSYDatabaseChargeRecord 【保存的表不一样：】
HSSYChargeRecord <==> HSSYChargeRecordForPole : 

