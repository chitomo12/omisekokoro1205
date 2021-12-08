//
//  IsShowPostDetailPopover.swift
//  PushNotificationSwiftUI
//
//  Created by 福田正知 on 2021/12/08.
//

import SwiftUI

class IsShowPostDetailPopover: ObservableObject {
    @Published var showSwitch: Bool = false
    @Published var showContent: Bool = false
    @Published var selectedPostDocumentUID: String = ""
}
