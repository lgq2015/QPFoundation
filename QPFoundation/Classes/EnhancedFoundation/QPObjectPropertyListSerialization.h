//
//  QPObjectPropertyListSerialization.h
//  QPFoundation
//
//  Created by keqiongpan@163.com on 16/7/30.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPPublicHeader.h>

/**
 *  该类可以支持从一个.plist文件生成一个对象实例。
 *  主要是利用下面四个原则对.plist文件进行解释。
 *      1、.plist中的数组解释为NSArray对象；
 *      2、.plist中的字典如果不含class键，则解释为NSDictionary对象；
 *      3、.plist中的字典如果含有class键，则解释为class值所表示的类的实例；
 *      4、.plist中的其它类型数据，通过setValue:forKeyPath:方法设置到其容器类实例。
 *
 *  该类可以使用Numbers的工作薄模板快速生成.plist文件。
 *
 *  工作薄模板（附QPObjectPropertyListTemplate.numbers文件）的初始字段设置如下：
 *    A1=序号
 *    B1=行数
 *    C1=class
 *    D1=object.plist
 *    E1=操作说明
 *    F1=操作数据
 *    G1=prepare.plist
 *    H1=array.plist
 *
 *    A2=列数
 *    B2=T(INDIRECT(ADDRESS(B3, C2)))
 *    C2=MAX(COLUMN(C2), IFERROR(INDIRECT(ADDRESS(ROW(C2), COLUMN(C2) + 1)), 0))
 *    D2:H2=<由C2递增序列得到>
 *
 *    A3=不要修改第1行到第4行的数据。
 *    B3=MAX(ROW(B3), IFERROR(INDIRECT(ADDRESS(ROW(B3) + 1, COLUMN(B3))), 0))
 *    C3=CONCATENATE("""""", C1, """"" = "" & IF(OR(""{"" = LEFT(" & ADDRESS(ROW(C3) + 2, COLUMN(C3), 3) & ", 1), ""("" = LEFT(" & ADDRESS(ROW(C3) + 2, COLUMN(C3), 3) & ", 1)), " & ADDRESS(ROW(C3) + 2, COLUMN(C3), 3) & ","""""""" & " & ADDRESS(ROW(C3) + 2, COLUMN(C3), 3) & " & """""""") & "";")
 *    D3=<由C3递增序列得到>
 *    E3=在class与plist之间插入/修改/删除若干列用于表示类的属性，并进行如下操作：1、按cmd+c键复制右边的单元格的内容；2、按delete键删除左边的单元格的内容；3、双击左边的单元格；4、按cmd+v键粘贴并回车。
 *    F3="=""{" & C4 & "}"""
 *      C4=INDIRECT(ADDRESS(ROW(F3) + 1, COLUMN(F3) - 3))
 *    F3="=""{" & INDIRECT(ADDRESS(ROW(F3) + 1, COLUMN(F3) - 3)) & "}"""
 *
 *    A4=IF(A3 = $A$3, -1, A3) + 1
 *      A3=INDIRECT(ADDRESS(ROW(A4) - 1, COLUMN(A4)))
 *      $A$3=INDIRECT("A3")
 *    A4=IF(INDIRECT(ADDRESS(ROW(A4) - 1, COLUMN(A4))) = INDIRECT("A3"), -1, INDIRECT(ADDRESS(ROW(A4) - 1, COLUMN(A4)))) + 1
 *    B4=<由B3递增序列得到>
 *    C4=IF(B4 = $B$4, "", B4 & " ") & C3)
 *      B4=INDIRECT(ADDRESS(ROW(C4), COLUMN(C4) - 1))
 *      $B$4=INDIRECT("B4")
 *      C3=INDIRECT(ADDRESS(ROW(C4) - 1, COLUMN(C4))
 *    C4=IF(INDIRECT(ADDRESS(ROW(C4), COLUMN(C4) - 1)) = INDIRECT("B4"), "", INDIRECT(ADDRESS(ROW(C4), COLUMN(C4) - 1)) & " ") & INDIRECT(ADDRESS(ROW(C4) - 1, COLUMN(C4)))
 *    D4=<由C4递增序列得到>
 *    E4=E3
 *    F4=F3
 *    G4=T(G3) & IF(LEN(G3) > 0, ", ", "") & IF(D4 = $D$4, "", D4)
 *      G3=INDIRECT(ADDRESS(ROW(G4) - 1, COLUMN(G4)))
 *      D4=HLOOKUP("object.plist", INDIRECT("A1:" & ADDRESS(ROW(G4), COLUMN(G4))), ROW(G4), 0)
 *      $D$4=HLOOKUP("object.plist", INDIRECT("A1:" & ADDRESS(ROW(G4), COLUMN(G4))), 4, 0)
 *    G4=T(INDIRECT(ADDRESS(ROW(G4) - 1, COLUMN(G4)))) & IF(LEN(INDIRECT(ADDRESS(ROW(G4) - 1, COLUMN(G4)))) > 0, ", ", "") & IF(HLOOKUP("object.plist", INDIRECT("A1:" & ADDRESS(ROW(G4), COLUMN(G4))), ROW(G4), 0) = HLOOKUP("object.plist", INDIRECT("A1:" & ADDRESS(ROW(G4), COLUMN(G4))), 4, 0), "", HLOOKUP("object.plist", INDIRECT("A1:" & ADDRESS(ROW(G4), COLUMN(G4))), ROW(G4), 0))
 *    H4="(" & G4 & ")"
 *      G4=HLOOKUP("prepare.plist", INDIRECT("A1:" & ADDRESS(ROW(H4), COLUMN(H4))), ROW(H4), 0)
 *    H4="(" & HLOOKUP("prepare.plist", INDIRECT("A1:" & ADDRESS(ROW(H4), COLUMN(H4))), ROW(H4), 0) & ")"
 */

@interface QPObjectPropertyListSerialization : NSObject

+ (id)objectWithContentsOfFoundationObjects:(id)foundationObjects
                                    options:(NSPropertyListMutabilityOptions)options;

+ (id)objectWithContentsOfPropertyListData:(NSData *)data
                                   options:(NSPropertyListReadOptions)options;

+ (id)objectWithContentsOfPropertyListStream:(NSInputStream *)stream
                                     options:(NSPropertyListReadOptions)options;

+ (id)objectWithContentsOfPropertyListNamed:(NSString *)propertyListName
                                    options:(NSPropertyListReadOptions)options;

@end
