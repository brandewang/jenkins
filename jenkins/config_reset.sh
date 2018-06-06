#批量修改发布包保留天数为-1
grep -r '<artifactDaysToKeep>' .|grep -v common|awk -F':' '{print $1}'|xargs -I {} -n 1 sed -i 's/<artifactDaysToKeep>.*<\/artifactDaysToKeep>/<artifactDaysToKeep>-1<\/artifactDaysToKeep>/g' {}
#批量修改构建保留天数为-1(构建包含 发布包 modules)
grep -r '<daysToKeep>' .|grep -v common|awk -F':' '{print $1}'|xargs -I {} -n 1 sed -i 's/<daysToKeep>.*<\/daysToKeep>/<daysToKeep>-1<\/daysToKeep>/g' {}
