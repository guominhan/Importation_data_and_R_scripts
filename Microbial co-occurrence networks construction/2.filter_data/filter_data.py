#先去一下重复的边

'''
unique_list=[]
out_file=open('new_sjz_edge.txt','w')
head=1
for line in open('sjz_edge.txt','r'):
    if head:
        head-=1
        out_file.write(line)
        continue
    list=[]
    list.append(line.strip().split('\t')[0])
    list.append(line.strip().split('\t')[1])
    new_list=sorted(list)
    # print(new_list)
    if new_list not in unique_list:
        unique_list.append(new_list)
        out_file.write(line)

#去重node
dict={}
out_file2=open('new_sjz_node.txt','w')
for line in open('sjz_node.txt','r'):
    if head:
        head-=1
        out_file2.write(line)
        continue
    if line.strip().split('\t')[0] not in dict:
        dict[line.strip().split('\t')[0]]=1
        out_file2.write(line)

'''


#尝试写成循环
filename_list=['nss','tst']
for filename in filename_list:
    unique_list = []
    str1='new_'+filename+'_edge.txt'
    out_file = open(str1, 'w')
    head = 1
    str2=filename+'_edge.txt'
    for line in open(str2, 'r'):
        if head:
            head -= 1
            out_file.write(line)
            continue
        list = []
        list.append(line.strip().split('\t')[0])
        list.append(line.strip().split('\t')[1])
        new_list = sorted(list)
        # print(new_list)
        if new_list not in unique_list:
            unique_list.append(new_list)
            out_file.write(line)

    # 去重node
    dict = {}
    str3='new_'+filename+'_node.txt'
    out_file2 = open(str3, 'w')
    str4=filename+'_node.txt'
    for line in open(str4, 'r'):
        if head:
            head -= 1
            out_file2.write(line)
            continue
        if line.strip().split('\t')[0] not in dict:
            dict[line.strip().split('\t')[0]] = 1
            out_file2.write(line)

