-- 增加新字段
alter table ks_ad_dw_dev.ad_app_feed_flow_effect_starbox_1d add columns (model_deep_conversion_bid bigint comment "计算平均深度出价分子", is_model_bid_cpa_bid bigint comment "计算平均客户出价分母") CASCADE;

-- 修改字段名称, 字段类型， 字段备注
alter table ks_ad_dw.audit_dwd_audit_process_df change column audit_result  audit_result  bigint comment "审核结果：0 待审核，1 审核成功，2 审核拒绝" CASCADE;

-- 修改字段的高级类型， 慎用
set hive.metastore.disallow.incompatible.col.type.changes=false;
unlock table ks_ad_dw.simplified_ad_log_report_hi;
alter table ks_ad_dw.simplified_ad_log_report_hi change column event_pay_net_service_novel  event_pay_net_service_novel  bigint comment "当日回传且归因成功的微信公众号内付费数" CASCADE;

-- 显示的表级别和分区级别和 EXTENDED 解析那个表占用锁
SHOW LOCKS <TABLE_NAME>;
SHOW LOCKS <TABLE_NAME> EXTENDED;
SHOW LOCKS <TABLE_NAME> PARTITION (<PARTITION_DESC>);
SHOW LOCKS <TABLE_NAME> PARTITION (<PARTITION_DESC>) EXTENDED;

-- 解除hive表锁
unlock table ks_ad_dw.audit_dwd_audit_process_df partition(p_date='20201025');

-- 关闭锁机制
set hive.support.concurrency=false;

-- hive建表语句
CREATE [EXTERNAL] TABLE [IF NOT EXISTS] table_name
[(col_name data_type [DEFAULT value] [COMMENT col_comment], ...)]
[COMMENT table_comment]
[PARTITIONED BY (col_name data_type [COMMENT col_comment], ...)]
[CLUSTERED BY (col_name [, col_name, ...]) [SORTED BY (col_name [ASC | DESC] [, col_name [ASC | DESC] ...])] INTO number_of_buckets BUCKETS] 
[STORED BY StorageHandler] -- 仅限外部表
[WITH SERDEPROPERTIES (Options)] -- 仅限外部表
[LOCATION OSSLocation]; -- 仅限外部表
[LIFECYCLE days]
[AS select_statement]

-- 从现有表创建相同表结构的新表
 CREATE TABLE [IF NOT EXISTS] table_name
 LIKE existing_table_name

-- 重命名表
 ALTER TABLE table_name RENAME TO table_name_new; 

-- 修改表生命周期
 ALTER TABLE table_name SET lifecycle days;

-- 锁定hive表 和 分区
lock table ks_ad_dw.ad_app_dsp_visitor_potrait_analysis_di partition(p_date='{{ ds_nodash-1 }}') exclusive;
lock table ks_ad_dw.ad_app_dsp_visitor_potrait_analysis_di partition(p_date='{{ ds_nodash-1 }}') shared;
-- exclusive 独占锁，一般在写入时
-- shared 共享锁，一般在读数据时
hive.lock.numretries -- 重试次数
hive.lock.sleep.between.retries -- 重试时sleep时间
-- hive 默认重试时间是60s, 高并发场景下，可以减少这个数值来提高job效率

-- hive 的groupby和orderby 采用位置序号代表字段名
set hive.groupby.orderby.position.alias = true;
select 
      p_date,
      account_id,
      product_name,
      first_industry_name,
      second_industry_name
from ks_ad_dw.ad_dim_account_info_df
where p_date = '{{ds_nodash}}'
group by 1,2,3,4,5
相当于
select 
      p_date,
      account_id,
      product_name,
      first_industry_name,
      second_industry_name
from ks_ad_dw.ad_dim_account_info_df
where p_date = '{{ds_nodash}}'
group by p_date, account_id, product_name, first_industry_name, second_industry_name

-- 增加新分区
ALTER TABLE day_table ADD PARTITION (dt='2008-08-08', hour='08') location '/path/pv1.txt' PARTITION (dt='2008-08-08', hour='09') location '/path/pv2.txt';

-- 删除分区
ALTER TABLE shphonefeature DROP IF EXISTS PARTITION(year = 2015, month = 10, day = 1);

-- 删除hive表中数据
truncate table table_name;

-- 随机取数
max(named_struct('r',rand(),'b',b)).b


-- 复杂结构的比较
max(Array)
max(named_struct)
每个元素按照顺序进行比较，数组自然就是按照位置从小到大，结构体是按照Schema的定义顺序从左到右。如果出现不相等的情况就分出了大小；否则按照长度本身进行比较，长的大、短的小。


-- analyze命令会统计表的行数、表的数据文件数、表占用的字节大小、列信息、TOP K统计信息等，进而优化查询、加快速度
ANALYZE TABLE [db_name.]tablename [PARTITION(partcol1[=val1], partcol2[=val2], ...)] COMPUTE STATISTICS;

ANALYZE TABLE [db_name.]tablename [PARTITION(partcol1[=val1], partcol2[=val2], ...)] COMPUTE STATISTICS FOR COLUMNS [column1] [,column2] [,column3] [,column4] ... [,columnn];

-- null 特殊处理
null false true ,sql 中存在着三种状态
coalesce(字段， 0) <> 1

-- 隐式类型转换
等号两边的类型不对齐时，会进行类型转换
'a' = 4 结果为 NULL
'4' = 4 结果为 TRUE
'5' = 4 结果为 FALSE
'' = 4 结果为 NULL

-- 设置执行任务时的yarn资源队列：
MapReduce引擎
进入hive命令行后： set mapreduce.job.queuename=队列名
在启动hive时指定    --hiveconf mapreduce.job.queuename=队列名

-- 查看表的属性
show tblproperties yourTableName

-- 数字判断
rlike '^\\d+$'

-- json解析效率
get_json_object
json_tuple

-- json 解析包 brickhouse
json_split('[1, 2, 3, 4]')
json_map(' { "key1":1.1, "key2":34.5, "key3":6.7 }', 'string,double')
from_json(' { "key1":[0,1,2], "key2":[3,4,5,6], "key3":[7,8,9] } ', 'map<string,array<int>>')
from_json(' { "key1":"string value", "key2":2.1, "key3":560000 }',
      named_struct("key1", "", "key2", cast(0.0 as double), "key3", cast(1 as bigint) ) )
to_json( array( 1, 2, 3, 4) )
" [ 1,2,3,4 ]"

to_json( named_struct("key1", 0, "key2", "a string val", "key3", array( 4,5,6), "key4", map("a",2.3,"b",5.6) ))
-- ' { "key1":0, "key2":"a string val", "key3":[4,5,6], "key4":{"a":2.3, "b":5.6} } '

to_json( 
      named_struct("camel_case", 1, 
                   "big_double", 9999.99, 
                   "the_really_cool_value", "a string val", 
                   "another_array", array( 4,5,6), 
                   "random_map", map("a",2.3,"b",5.6) ), true)
-- {"camelCase":1,"bigDouble":9999.99,"theReallyCoolValue":"a string val","anotherArray":[4,5,6],"randomMap":{"b":5.6,"a":2.3}}

-- udf 加载
add jar viewfs://hadoop-lt-cluster/home/dp/data/udf/online/kuaishou-ads-udf-1.0-SNAPSHOT.jar;
create temporary function suv_bin as 'com.kuaishou.dp.bitmap.UvBinaryUDAF';
create temporary function suv as 'com.kuaishou.dp.bitmap.UvUDAF';

-- spark 语法特殊
over 后面一定要有 order by 

-- 创建临时函数
create temporary macro params_to_json(params string)
    case --when substring(params,0,1)='{' and substring(params,length(params),1)='}' then params
         when params like '{\\045}' then params
         when nvl(params, '') == '' then ''
         when params like '%=%' then
             case when params like '%&%' then brickhouse.to_json(str_to_map(params,'&','='))
                  else brickhouse.to_json(str_to_map(params,',','='))
                 end
         else params
        end;

-- grouping_id 的生成规则
spark: 距离group by最近的字段在低位，且维度存在置 0，不存在置 1
eg: group by a, b, c, d with cube
a, b, c => 1000 => 8

hive: 距离group by最近的字段在高位，且维度存在置 1，不存在置 0

-- sql 中 or and 优先级
select  1 from student where 1=0 or 1=1 and 1 = 0; 等价于
select  1 from student where 1=0 or (1=1 and 1 = 0);

-- date_format('2022-01-09', 'yyyyWW')
date_format 转化为周时，按照周日为一周的第一天


-- ks grouping_id 转 字段名
default.getCubeGroupName(grouping__id,'gender,age_range,platform,paid_tag,is_first_send_gift,product,live_user_pay_role')  as grouping__name,

-- ks spark失败后不会智能采取mr执行
set hive.smart.router.failback.enable=false;

set spark.stage.maxConsecutiveAttempts=10;
set spark.io.compression.codec=zstd;
set spark.sql.adaptive.maxNumPostShufflePartitions=1000;

set beacon.smart.router.schema.consistency.check.enable=false;

set spark.sql.adaptive.maxNumPostShufflePartitions=2500;
set spark.io.compression.codec=zstd;
set hive.specify.execution.engine.enforce.name=spark;
set spark.sql.adaptive.join.enabled=true;
set spark.sql.adaptive.skewedJoin.enabled=true;

SET hive.auto.convert.join=true;
SET hive.mapjoin.smalltable.filesize=200000000;
SET hive.exec.parallel=true;
SET hive.exec.parallel.thread.number=20;
SET mapreduce.map.memory.mb=4096;

set beacon.smart.router.schema.consistency.check.enable=false;
set spark.remote.shuffle.enable=false;
set spark.remote.shuffle.useByShuffleSize.enabled=false;
set spark.file.transferTo=false;
set spark.shuffle.file.buffer=512k;
set spark.shuffle.unsafe.file.ouput.buffer=2m;
set spark.reducer.maxSizeInFlight=96m;
set spark.reducer.maxReqSizeShuffleToMem=200m;
set spark.shuffle.io.maxRetries=10;
set spark.shuffle.io.retryWait=30s;
set spark.reducer.maxBlocksInFlightPerAddress=200;
set spark.reducer.maxReqsInFlight=500;
set spark.shuffle.registration.timeout=120000;
set spark.shuffle.registration.maxAttempst=5;
set spark.io.compression.zstd.blockSize=512KB;
set spark.block.failures.beforeLocationRefresh=2;
set hive.mapred.mode=nonstrict;
set hive.strict.checks.cartesian.product=false;
set spark.sql.adaptive.minNumPostShufflePartitions=100;
set spark.executor.memory=32g;
set parquet.block.size=16777216;
set spark.hadoop.parquet.block.size=16777216;

set spark.sql.statistics.fallBackToHdfs=true;
长且窄的表
set spark.sql.statistics.fallBackToHdfs=true;
set spark.sql.autoBroadcastJoinThreshold=50000000;


    



