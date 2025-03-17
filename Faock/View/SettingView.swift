//
//  SettingView.swift
//  Faock
//
//  Created by 方君宇 on 2025/3/11.
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject var appStorage: AppStorageManager  // 通过 EnvironmentObject 注入
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    // 发生邮件
    func sendEmail() {
            let email = "fangjunyu.com@gmail.com"
            let subject = "Faock"
            let body = "Hi fangjunyu,\n\n"
            
            // URL 编码参数
            let urlString = "mailto:\(email)?subject=\(subject)&body=\(body)"
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            
            if let url = URL(string: urlString ?? "") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                } else {
                    // 处理无法打开邮件应用的情况
                    print("Cannot open Mail app.")
                }
            }
        }
    
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                let width = geo.frame(in: .global).width
                let height = geo.frame(in: .global).height
                ScrollView(showsIndicators: false) {
                    // 留白
                    Spacer().frame(height: 10)
                    // 外层框架
                    VStack(alignment: .center) {
                        // 游戏会员
                        if appStorage.isInAppPurchase {
                            NavigationLink(destination: {
                                GameMembershipView()
                            }, label: {
                                HStack {
                                    // 图标
                                    Image("king")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                    Spacer().frame(width: 20)
                                    Text("Game membership")
                                    Spacer()
                                    Text("Permanent")
                                        .fontWeight(.bold)
                                        .font(.caption)
                                }
                                .foregroundColor(.white)
                                .padding(.vertical,10)
                                .padding(.horizontal,14)
                                .background(colorScheme == .light ? Color(hex: "2F438D") : Color(hex:"1F1F1F"))
                                .cornerRadius(10)
                                .tint(colorScheme == .light ? .black : .white)
                                .lineLimit(1) // 限制文本为一行
                                .minimumScaleFactor(0.3) // 最小缩放比例
                            })
                        } else {
                            
                            NavigationLink(destination: {
                                GameMembershipView()
                            }, label: {
                                HStack {
                                    // 图标
                                    Image("king2")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                    Spacer().frame(width: 20)
                                    Text("Get game membership")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .padding(.vertical,10)
                                .padding(.horizontal,14)
                                .background(colorScheme == .light ? .white : Color(hex:"1F1F1F"))
                                .cornerRadius(10)
                                .tint(colorScheme == .light ? .black : .white)
                                .lineLimit(1) // 限制文本为一行
                                .minimumScaleFactor(0.3) // 最小缩放比例
                            })
                        }
                        
                        // 分割 - 间距
                        Spacer().frame(height: 16)
                        
                        // 音效
                        HStack {
                            // 图标
                            Rectangle()
                                .frame(width: 30, height: 30)
                                .foregroundColor(Color(hex: "BD27B1"))
                                .cornerRadius(4)
                                .overlay {
                                    Image(systemName: "music.note")
                                        .foregroundColor(.white)
                                }
                            Spacer().frame(width: 20)
                            Text("Sound effects")
                                .lineLimit(1) // 限制文本为一行
                                .minimumScaleFactor(0.5) // 最小缩放比例
                            Spacer()
                            Toggle(isOn: $appStorage.Music){}
                                .tint(.green)
                        }
                        .padding(.vertical,10)
                        .padding(.horizontal,14)
                        .background(colorScheme == .light ? .white : Color(hex:"1F1F1F"))
                        .cornerRadius(10)
                        .tint(colorScheme == .light ? .black : .white)
                        
                        // 分割 - 间距
                        Spacer().frame(height: 16)
                        
                        // 管理游戏数据、方块皮肤、棋盘皮肤
                        VStack(spacing: 0) {
                            // 管理游戏数据
                            NavigationLink(destination: {
                                ManageGameDataViews()
                            }, label: {
                                HStack {
                                    // 图标
                                    Rectangle()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(Color(hex: "277EBD"))
                                        .cornerRadius(4)
                                        .overlay {
                                            Image(systemName: "gamecontroller.fill")
                                                .foregroundColor(.white)
                                                .font(.footnote)
                                        }
                                    Spacer().frame(width: 20)
                                    Text("Manage game data")
                                        .lineLimit(1) // 限制文本为一行
                                        .minimumScaleFactor(0.5) // 最小缩放比例
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .padding(.vertical,10)
                                .padding(.horizontal,14)
                                .background(colorScheme == .light ? .white : Color(hex:"1F1F1F"))
                                .cornerRadius(10)
                                .tint(colorScheme == .light ? .black : .white)
                            })
                            
                            // 分割线
                            Rectangle().frame(width: .infinity,height: 0.5)
                                .foregroundColor(.gray)
                                .padding(.leading,60)
                            
                            // 方块皮肤
                            NavigationLink(destination: {
                                BlockSkinView()
                            }, label: {
                                HStack {
                                    // 图标
                                    Rectangle()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(Color(hex: "34BD27"))
                                        .cornerRadius(4)
                                        .overlay {
                                            Image(systemName: "stop.fill")
                                                .foregroundColor(.white)
                                        }
                                    Spacer().frame(width: 20)
                                    Text("Block skins")
                                        .lineLimit(1) // 限制文本为一行
                                        .minimumScaleFactor(0.5) // 最小缩放比例
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .padding(.vertical,10)
                                .padding(.horizontal,14)
                                .background(colorScheme == .light ? .white : Color(hex:"1F1F1F"))
                                .cornerRadius(10)
                                .tint(colorScheme == .light ? .black : .white)
                            })
                            
                            
                            // 分割线
                            Rectangle().frame(width: .infinity,height: 0.5)
                                .foregroundColor(.gray)
                                .padding(.leading,60)
                            
                            // 棋盘皮肤
                            NavigationLink(destination: {
                                ChessboardSkinView()
                            }, label: {
                                HStack {
                                    // 图标
                                    Rectangle()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(Color(hex: "27BABD"))
                                        .cornerRadius(4)
                                        .overlay {
                                            Image(systemName: "rectangle.checkered")
                                                .foregroundColor(.white)
                                                .font(.footnote)
                                        }
                                    Spacer().frame(width: 20)
                                    Text("Board skins")
                                        .lineLimit(1) // 限制文本为一行
                                        .minimumScaleFactor(0.5) // 最小缩放比例
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .padding(.vertical,10)
                                .padding(.horizontal,14)
                                .background(colorScheme == .light ? .white : Color(hex:"1F1F1F"))
                                .cornerRadius(10)
                                .tint(colorScheme == .light ? .black : .white)
                            })
                        }
                        .background(colorScheme == .light ? .white : Color(hex:"1F1F1F"))
                        .cornerRadius(10)

                        // 分割 - 间距
                        Spacer().frame(height: 16)
                        
                        // 问题反馈、使用条款、隐私政策
                        VStack(spacing: 0) {
                            // 问题反馈
                            Button(action: {
                                sendEmail()
                            }, label: {
                                HStack {
                                    // 图标
                                    Rectangle()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(Color(hex: "BD5F27"))
                                        .cornerRadius(4)
                                        .overlay {
                                            Image(systemName: "ladybug.fill")
                                                .foregroundColor(.white)
                                        }
                                    Spacer().frame(width: 20)
                                    Text("Problem feedback")
                                        .lineLimit(1) // 限制文本为一行
                                        .minimumScaleFactor(0.5) // 最小缩放比例
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .padding(.vertical,10)
                                .padding(.horizontal,14)
                                .background(colorScheme == .light ? .white : Color(hex:"1F1F1F"))
                                .cornerRadius(10)
                                .tint(colorScheme == .light ? .black : .white)
                            })
                            
                            
                            // 分割线
                            Rectangle().frame(width: .infinity,height: 0.5)
                                .foregroundColor(.gray)
                                .padding(.leading,60)
                            
                            // 使用条款
                            Link(destination: URL(string: "https://fangjunyu.com/2025/03/13/%e6%96%b9%e6%96%b9%e5%9d%97%e6%b8%b8%e6%88%8f%e4%bd%bf%e7%94%a8%e6%9d%a1%e6%ac%be/")!) {
                                HStack {
                                    // 图标
                                    Rectangle()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(Color(hex: "BDAD27"))
                                        .cornerRadius(4)
                                        .overlay {
                                            Image(systemName: "book.pages.fill")
                                                .foregroundColor(.white)
                                        }
                                    Spacer().frame(width: 20)
                                    Text("Terms of use")
                                        .lineLimit(1) // 限制文本为一行
                                        .minimumScaleFactor(0.5) // 最小缩放比例
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .padding(.vertical,10)
                                .padding(.horizontal,14)
                                .background(colorScheme == .light ? .white : Color(hex:"1F1F1F"))
                                .cornerRadius(10)
                                .tint(colorScheme == .light ? .black : .white)
                            }
                            
                            
                            // 分割线
                            Rectangle().frame(width: .infinity,height: 0.5)
                                .foregroundColor(.gray)
                                .padding(.leading,60)
                            
                            // 隐私政策
                            Link(destination: URL(string: "https://fangjunyu.com/2025/03/13/%e6%96%b9%e6%96%b9%e5%9d%97%e6%b8%b8%e6%88%8f%e9%9a%90%e7%a7%81%e6%94%bf%e7%ad%96/")!) {
                                HStack {
                                    // 图标
                                    Rectangle()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(Color(hex: "27BD47"))
                                        .cornerRadius(4)
                                        .overlay {
                                            Image(systemName: "eye.slash.fill")
                                                .foregroundColor(.white)
                                                .font(.footnote)
                                        }
                                    Spacer().frame(width: 20)
                                    Text("Privacy policy")
                                        .lineLimit(1) // 限制文本为一行
                                        .minimumScaleFactor(0.5) // 最小缩放比例
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .padding(.vertical,10)
                                .padding(.horizontal,14)
                                .background(colorScheme == .light ? .white : Color(hex:"1F1F1F"))
                                .cornerRadius(10)
                                .tint(colorScheme == .light ? .black : .white)
                            }
                        }
                        .background(colorScheme == .light ? .white : Color(hex:"1F1F1F"))
                        .cornerRadius(10)
                        
                        // 分割 - 间距
                        Spacer().frame(height: 16)
                        
                        // 关于我们、鸣谢、开源
                        VStack(spacing: 0) {
                            // 关于我们
                            NavigationLink(destination: {
                                AboutUsView()
                            }, label: {
                                HStack {
                                    // 图标
                                    Rectangle()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(Color(hex: "2730BD"))
                                        .cornerRadius(4)
                                        .overlay {
                                            Image(systemName: "figure.2")
                                                .foregroundColor(.white)
                                                .font(.footnote)
                                        }
                                    Spacer().frame(width: 20)
                                    Text("About us")
                                        .lineLimit(1) // 限制文本为一行
                                        .minimumScaleFactor(0.5) // 最小缩放比例
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .padding(.vertical,10)
                                .padding(.horizontal,14)
                                .background(colorScheme == .light ? .white : Color(hex:"1F1F1F"))
                                .cornerRadius(10)
                                .tint(colorScheme == .light ? .black : .white)
                            })
                            
                            
                            // 分割线
                            Rectangle().frame(width: .infinity,height: 0.5)
                                .foregroundColor(.gray)
                                .padding(.leading,60)
                            
                            // 鸣谢
                            NavigationLink(destination: {
                                AcknowledgementsView()
                            }, label: {
                                HStack {
                                    // 图标
                                    Rectangle()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(Color(hex: "B327BD"))
                                        .cornerRadius(4)
                                        .overlay {
                                            Image(systemName: "face.smiling.inverse")
                                                .foregroundColor(.white)
                                        }
                                    Spacer().frame(width: 20)
                                    Text("Acknowledgements")
                                        .lineLimit(1) // 限制文本为一行
                                        .minimumScaleFactor(0.5) // 最小缩放比例
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .padding(.vertical,10)
                                .padding(.horizontal,14)
                                .background(colorScheme == .light ? .white : Color(hex:"1F1F1F"))
                                .cornerRadius(10)
                                .tint(colorScheme == .light ? .black : .white)
                            })
                            
                            
                            // 分割线
                            Rectangle().frame(width: .infinity,height: 0.5)
                                .foregroundColor(.gray)
                                .padding(.leading,60)
                            
                            // 开源
                            NavigationLink(destination: {
                                OpenSourceView()
                            }, label: {
                                HStack {
                                    // 图标
                                    Rectangle()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(Color(hex: "BD8527"))
                                        .cornerRadius(4)
                                        .overlay {
                                            Image(systemName: "lock.open.fill")
                                                .foregroundColor(.white)
                                        }
                                    Spacer().frame(width: 20)
                                    Text("Open source")
                                        .lineLimit(1) // 限制文本为一行
                                        .minimumScaleFactor(0.5) // 最小缩放比例
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .padding(.vertical,10)
                                .padding(.horizontal,14)
                                .background(colorScheme == .light ? .white : Color(hex:"1F1F1F"))
                                .cornerRadius(10)
                                .tint(colorScheme == .light ? .black : .white)
                            })
                        }
                        .background(colorScheme == .light ? .white : Color(hex:"1F1F1F"))
                        .cornerRadius(10)
                    }
                    .frame(width: width * 0.9)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    Spacer().frame(height: 30)
                    Text("\(Bundle.main.appVersion).\(Bundle.main.appBuild)")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    // 底部留白
                    Spacer().frame(height: 100)
                }
                .frame(width: .infinity, height: .infinity,alignment: .center)
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            dismiss()
                        }, label: {
                            Text("Return")
                                .fontWeight(.bold)
                                .foregroundColor(colorScheme == .light ? .black : .white)
                        })
                    }
                }
            }
            .background(colorScheme == .light ? Color(hex: "E9E9E9") : .black)
        }
    }
}

#Preview {
    return SettingView()
        .environmentObject(AppStorageManager.shared)
        .environmentObject(IAPManager.shared)
        .environment(\.locale, .init(identifier: "de")) // 设置其他语言
}
