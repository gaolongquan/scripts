#!/bin/bash
# 思路:每隔2分钟取出前2分钟的日志，针对频繁访问的IP，并排除内网和本地IP，如果这2分钟的日志中的访问IP超过60次，那么会被IPTABLES永久封掉

#自定义日志位置
Log_path='/data/wwwlogs/www.domain.com.log'
Log_time=`date -d '+2 minute ago' '+[%d/%b/%Y:%H:%M'`
Tmp_log='/tmp/nginx.log'
LogResult='/tmp/nginx.badip.log'
#自定义白名单IP
tac ${Log_path}|awk '{if(substr($4,0,18) == Log_time){print $0}else if($4<Log_time){exit}}' Log_time="${Log_time}"|grep -v 172.16|grep -v 127.0.0.1|grep -v 192.168  > ${Tmp_log}
#自定义阈(yu)值
Badip=`cat ${Tmp_log}|awk '{print $1}'|sort|uniq -c|sort -nr |awk '$1 > 60 {print $2}'`
for i in `echo ${Badip}`
  do
   grep $i $LogResult
   if [ $? -ne 0 ];then
#自定义动作,也可以只是记录下来，并通知，而不是直接封掉！
    /sbin/iptables -I INPUT -s $i -p TCP --dport 80 -j DROP 
    /sbin/iptables -I INPUT -s $i -p TCP --dport 443 -j DROP
    echo $i >> $LogResult
   fi
done

#解封
#可定时重启iptables
#/sbin/iptables -D INPUT -s 被封IP -p TCP --dport 被封端口 -j DROP  

#其他补充
# 建议使用openresty+waf
