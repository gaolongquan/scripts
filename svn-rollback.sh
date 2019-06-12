#!/bib/bash
#上线不规范，运维俩行泪

#有些简单的部署场景是这样的，先通过subversion版本控制，然后测试环境通过钩子自动更新，最后在正式环境上svn up 文件或目录(一般不会直接全量更新svn up)
#偶尔就有开发说，我要回退到上一个版本。
#ok,你更新了哪些文件，我们就手动去回退哪些文件，清楚明白！

#自定义输出颜色
warn_echo()
        {
            printf  "\033[36m $* \033[0m\n"
        }
fail_echo()
        {
            printf "\033[31m $* \033[0m\n"
        }

succ_echo()
        {
            printf "\033[32m $* \033[0m\n"
        }

if [ $# != 1 ];then
        fail_echo "Usage:  sh $0  /data/web/glq/html/index.html"
        fail_echo "只能带一个文件或目录回退，如果你了解你的操作，可以整个项目回退到上一个版本，如，直接sh $0 /data/web/glq"
  exit 1
else

svn info $1 >/dev/null
if [ $? -ne 0 ];then
fail_echo "版本库里没有这个文件或目录,退出"
exit 0
fi

#列出最近的几个版本号
list_version=$(svn log $1 --limit 5|sed '1d'|sed '$d'|awk -F '|' '{print $1}')
#要回退的前一个版本号
rollback_version=$(svn log $1 --limit 2|tac |sed -n 4p|awk '{print $1}') 
warn_echo "列出最近的几个版本号"
echo "$list_version"
echo ""
warn_echo "回退到上一个版本,请直接回车，回退到指定版本,输入如r1024。"
read answer
if [ -z "$answer" ];then
svn up $1 -r $rollback_version
succ_echo "回退成功"
else 

svn up $1 -r $answer
if [ $? -eq 0 ];then
succ_echo "回退成功"
else
fail_echo "可能没有这个版本号,请输入如 r1024 版本号"
fi

fi

fi
