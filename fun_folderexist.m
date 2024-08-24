function fun_folderexist(folder)
if exist(folder)==0 %%判断文件夹是否存在
    mkdir(folder);  %%不存在时候，创建文件夹
    disp(['路径为：',folder,' 的输出数据文件夹创建']); %%如果文件夹存在，输出:输出路径已创建
else
    disp(['路径为：',folder,' 的输出数据文件夹已存在']); %%如果文件夹存在，输出:输出路径已创建
end
end