# The ToDo

let us: Go! 2022 summer

## Features

- UIKit 으로 만들어진 ToDo 샘플 앱 입니다.
- UI는 스토리보드로 구성되었습니다.
- UI구성과정은 commit으로 표현하지 않았습니다.
- commit 단위로 코드가 진행되는 과정을 보시면 됩니다.
- Protocol 을 우선해서 만들고, 나중에 구현을 해가는 과정을 보여줍니다.

## Links

- [Slide](https://www.slideshare.net/ChiwonSong/20220716pop)


## Documetation 

이 글은 [let us:Go! 2022 Summer](https://let-us-go-2022-summer.vercel.app/) 에서 발표된 [곰튀김](https://github.com/iamchiwon)님의 [만들면서 느껴보는 POP](https://www.youtube.com/watch?v=q_mPAZB3RQY&list=LL&index=3&t=25s)를 글로 정리한 것입니다. 샘플코드는 [여기](https://github.com/iamchiwon/TheToDo), 슬라이드는 [여기](https://www.slideshare.net/ChiwonSong/20220716pop)에 있으니 보시는데 참고하시기 바랍니다. 

POP란 `프로토콜 지향 프로그래밍(Protocol Oriented Programming)` 을 뜻합니다. 2015년 [WWDC에서 애플은 Swift를 소개하면서 프로토콜 지향 프로그래밍 언어](https://developer.apple.com/videos/play/wwdc2015/408/)라고 말했지요. 우리가 잘 알고 있고, 지금도 흔히 사용하는 `객체 지향 프로그래밍(Object Oriented Programming)` 이 객체의 사용을 지향하는 프로그래밍 인 것처럼 `Protocol Oriented Programming` 또한 프로토콜을 지향해라 또는 프로토콜을 우선하는 프로그래밍 이라고 볼 수 있을 것 같습니다. 

이 글에서는 간단하게 구현된 ToDo 앱을 `프로토콜 지향 프로그래밍(Protocol Oriented Programming)`으로 리팩토링하면서 어떻게 POP를 사용하는지, POP를 통해 얻는 이점은 무엇인지에 대해 알아보도록 하겠습니다. 

일단 완성된 앱의 동작은 아래와 같습니다. 앱은 메인화면인 `ToDoListViewController`와 내부의 테이블뷰 셀인 `ToDoItemTableViewCell` 있고, `ToDo`를 추가할 수 있는 `AddItemViewController`를 가지고 있는 아주 간단한 앱입니다.                
          
![](https://velog.velcdn.com/images/dev_kickbell/post/6b9792a8-d81f-4695-9356-731d95fa1ee0/image.gif)           
            
현재 리팩토링 전의 코드는 아래와 같은데요. `//1.` 을 보면 데이터를 `todoItems`라는 배열에 저장하고 있고, `//2.`  `func prepare(for segue:)` 를 통해 화면을 이동합니다. 그리고 `toVC.createdItem` 라는 `Callback Closure`가 있어서 다시 메인화면으로 돌아왔을 때 `todoItems` 배열에 `ToDo`를 `append()`를 해주고 `tableView.reloadData()`를 호출해서 화면을 리로드 해주고 있습니다. 마지막으로 `//3.` 에서는 현재 `todoItems` 배열의 데이터를 셀에 렌더링해주는 코드가 구현되어 있습니다.

```swift
import UIKit

class ToDoListViewController: UITableViewController {
	//1.
    var todoItems: [(title: String, createdAt: Date)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreateNewItem", let toVC = segue.destination as? AddItemViewController {
            toVC.createdItem = { [weak self] title, createdAt in
            	//2.
                self?.todoItems.append((title, createdAt))
                self?.tableView.reloadData()
            }
        }
    }
}

extension ToDoListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        todoItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath) as? ToDoItemTableViewCell else {
            fatalError("tableViewCell has not dequeued!")
        }
        
		//3.
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm:ss"

        let item = todoItems[indexPath.row]
        cell.itemTitle.text = item.title
        cell.updatedAt.text = formatter.string(from: item.createdAt)

        return cell
    }
}
```

이제 이 기본으로 구현된 코드를 `프로토콜 지향 프로그래밍(Protocol Oriented Programming`으로 변경해보도록 하겠습니다. 리팩토링의 `핵심`은 기존에 `비즈니스 로직`이었던 부분을 `프로토콜로 추상화`하는 것 입니다. 

```swift
//1.
protocol ToDoService {
    func create(title: String)
    func count() -> Int
    func item(at: Int) -> ToDo
}

struct ToDo: Identifiable {
    var id: String
    var title: String
    var done: Bool
    let createdAt: Date
}

import UIKit

class ToDoListViewController: UITableViewController {
	//1.
    let service: ToDoService

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreateNewItem", let toVC = segue.destination as? AddItemViewController {
            toVC.createdItem = { [weak self] title, createdAt in
            	//2.
                self?.service.create(title: title)
                self?.tableView.reloadData()
            }
        }
    }
}

extension ToDoListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.service.count()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath) as? ToDoItemTableViewCell else {
            fatalError("tableViewCell has not dequeued!")
        }
		//3.
        let item = service.item(at: indexPath.row)
        cell.todo = item
        return cell
    }
}
```

코드에서 바뀐 부분을 짚어볼게요. 

1. 앱의 비즈니스 로직을 추상화하기 위해 `ToDoService` 프로토콜을 생성했어요. 그래서 `var todoItems` -> `let service: ToDoService`로 대체했습니다. 그리고나서 `ToDo` 모델도 만들어주었어요. 
2. 생성한 `let service: ToDoService` 를 통해 `todoItems.append` -> `service.create()`로 대체했어요.
3. `item`을 가져오는 부분도 `service.item(at:)`으로 대체되었습니다. 

그리고 이제 `ToDoService`을 준수하는 실제 구현 클래스인 `ToDoServiceImpl`를 구현하겠습니다. 인터페이스인 `ToDoService` 프로토콜은 기능을 추상화만 하고 있고, 비즈니스 로직의 실제 구현과 동작은 `ToDoServiceImpl` 에서 구현합니다. 그리고 기존의 `ToDoListViewController` 의 `let service: ToDoService` 인스턴스에 `ToDoServiceImpl` 구현체를 주입해줍니다. 

```swift
import UIKit

class ToDoListViewController: UITableViewController {
    let service: ToDoService = ToDoServiceImpl()
    ...
}

import Foundation

class ToDoServiceImpl: ToDoService {
    private var todoItems: [ToDo] = []

    func create(title: String) {
        let todo = ToDo(id: UUID().uuidString,
                        title: title,
                        done: false,
                        createdAt: Date())
        todoItems.append(todo)
    }
    
    func count() -> Int {
        return todoItems.count
    }
    
    func item(at index: Int) -> ToDo {
        return todoItems[index]
    }
}
```

그리고 나서 앱을 다시 실행해보면, 앱은 정상적으로 이전과 동일하게 동작합니다. 저희가 해준 일은 `ToDoService` 프로토콜을 만들어서 비즈니스 로직을 추상화하고, 실제 구현체인 `ToDoServiceImpl`을 통해 기능을 구현해주었죠. 기존에 비즈니스 로직이 `ToDoListViewController`에서 여러 곳에 흩어져 있던 것과는 다르게 리팩토링 후에는 `ToDoServiceImpl` 안에 비즈니스 로직이 모여있으니 `코드 응집도`가 높아졌고 기능의 수정이 필요하다고 하더라도 `유지보수`에 상대적으로 용이합니다.

추가로 `Todo` 앱의 `저장된 데이터`를 현재 `메모리에 저장하는 방식`에서 `UserDefault를 사용해 앱 내에 저장하는 방식`으로 바꿔보도록 하겠습니다. 먼저 위에서 한 것과 똑같이 프로토콜부터 만들어줍니다. 저장을 하는 역할이니 이름은 `Repository` 가 좋을 것 같네요. 그리고 필요한 기능으로 `load()`, `save()`를 넣었습니다. 그리고나서 아직 실제 기능이 구현되진 않았지만, `ToDoServiceImpl` 클래스에서 해당 프로토콜을 `//1.`생성자 주입되도록 바꿔주고 `todo`가 생성될 때마다 `//2.` 데이터를 저장해주는 로직을 넣어주도록 하겠습니다. 

```swift
protocol Repository {
    func load() -> [ToDo]
    func save(todos: [ToDo])
}

import Foundation

class ToDoServiceImpl: ToDoService {
    //1.
    private let repository: Repository
     
    init(repository: Repository) {
        self.repository = repository
        todoItems = repository.load()
    }
    
    //2.
    private func save() {
        repository.save(todos: todoItems)
    }
    
    private var todoItems: [ToDo] = []
 
    func create(title: String) {
        let todo = ...
        todoItems.append(todo)
        //2.
        save()
    }
    ...
}
```

그리고 이제 `Repository`를 준수하는 실제 구현체인 `//1.` `UserDefaultRepository` 클래스를 생성하고 기능을 구현해줍니다. `ToDoListViewController` 에서도 `//2.`일부 코드를 수정해야 합니다. 

```swift
import Foundation
//1.
class UserDefaultRepository: Repository {
    private let TodoKey = "todos"
    private var database: UserDefaults { UserDefaults.standard }

    func load() -> [ToDo] {
        guard let json = UserDefaults.standard.string(forKey: TodoKey),
              let data = json.data(using: .utf8) else {
            return []
        }
        return (try? JSONDecoder().decode([ToDo].self, from: data)) ?? []
    }

    func save(todos: [ToDo]) {
        guard let data = try? JSONEncoder().encode(todos),
              let json = String(data: data, encoding: .utf8) else {
            return
        }
        UserDefaults.standard.set(json, forKey: TodoKey)
    }
}

class ToDoListViewController: UITableViewController {
    //2.
    let service: ToDoService = ToDoServiceImpl(repository: UserDefaultRepository())
    ...
}
```

다시 앱을 실행해보면, `UserDefault`를 통해 앱을 종료 후 재실행해도 정상적으로 `저장된 ToDo 데이터`가 사라지지 않는 것을 볼 수 있습니다. 이미 위에서 구현해봤지만, `Repository` 프로토콜도 `ToDoService` 프로토콜과 마찬가지로 비즈니스 로직을 추상화하고, 실제 구현은 추상화한 프로토콜을 준수하는 클래스에서 구현한다는 점이 프로세스가 똑같다고 볼 수 있습니다.        
        
여기서 한 걸음 더 나아가볼까요 ?         
        
이번엔 [Swinject](https://github.com/Swinject/Swinject) 이라는 의존성 주입 프레임워크를 추가할 겁니다. `Swinject`은 의존성을 편하게 주입할 수 있게 해주는 `의존성 주입 프레임워크` 인데요. 크게 어렵지 않아서 아래의 예제 코드만 보셔도 이해하시기 충분하실 겁니다. 

먼저 `Swinject` 을 설치하고, `AppDelegate`에서 `import Swinject`해준 뒤, `AppDelegate` 코드를 수정합니다. 
```swift
import Swinject
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    //1.
    let container = Container()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //2.
        container.register(Repository.self) { _ in UserDefaultRepository() }
        container.register(ToDoService.self) { c in
            let repository = c.resolve(Repository.self)!
            return ToDoServiceImpl.init(repository: repository)
        }
        return true
    }
    
}

//3.
func Inject<Service>(_ serviceType: Service.Type) -> Service? {
    (UIApplication.shared.delegate as? AppDelegate)?.container.resolve(serviceType)
}
```

1. `Swinject`에서 지원하는 `Container` 인스턴스를 생성합니다. `Container` 에서는 서비스를 등록, 검색할 수 있습니다. 
2. `ToDo`에서 내가 사용하게 될 서비스들을 `register` 합니다. 등록된 서비스들은 `resolve` 를 통해 검색해서 불러올 수 있습니다.
3. `AppDelegate`를 불러오고 `container`에서 `resolve`를 호출할 수 있는 메소드를 추가했습니다. 

이렇게 코드를 수정해주면, 기존의 코드 `//1.` 를 `//2.` 처럼 구현이 가능해집니다. 

```swift
//1.
class ToDoListViewController: UITableViewController {
    let service: ToDoService = ToDoServiceImpl(repository: UserDefaultRepository())
    ...
}
//2.
class ToDoListViewController: UITableViewController {
    let service = Inject(ToDoService.self)!
    ...
}
```

이게 무슨 `의미`가 있을까요 ? 		

이것에 대한 답변은 `느슨한 결합(Loose Coupling)` 입니다. 지금 현재 구현된 프로젝트의 `flow`는 아래의 그림과 같습니다. 유심히 봐야할 부분은 지금 저희는 **_`let service` 인스턴스에 직접적으로 구현하는 구현체인 `ToDoServiceImpl()` 가 아닌 `ToDoService.self` 프로토콜 타입을 주입시키고 있다는 겁니다._** 
			
수정 전의 코드인 `//1.` 이었다면 화살표는 `TodoViewController -> TodoServiceImpl` 로 이어져야 할 겁니다. 하지만 지금의 코드는 `//2.` 처럼  `TodoViewController -> TodoService <･･ TodoServiceImpl` 로 구현되어 있습니다. 이 말인 즉슨, 저 `TodoServiceImpl` 위치에 `TodoService` 를 준수하는 클래스라면 꼭 `TodoServiceImpl`가 아니어도 들어갈 수 있다는 뜻 입니다. 그래서 `TodoService` 과 `TodoServiceImpl` 사이가 점선 화살표로 이어져있는 것이고 이것을 `제어의 역전(Inversion of Control)` 또는 `느슨한 결합(Loose Coupling)`이라고 합니다. 

![](https://velog.velcdn.com/images/dev_kickbell/post/a3413222-0b65-4b39-82a0-bd0e823f9966/image.png)

그렇다면 이게 무슨 `장점`이 있을까요 ? 				

`느슨한 결합(Loose Coupling)`은 `확장에는 열려(Open)있고 수정에는 닫혀(Close)`있습니다. 이것을 조금 더 풀어서 말하면 프로토콜을 사용해서 느슨한 결합을 하게 되면 `새로운 기능을 개발하거나 기존 기능을 수정하고 확장하는게 쉽다`는 뜻입니다. 		

예를 들어 볼까요 ? 		

지금 저희는 `ToDo`의 데이터를 `UserDefaultRepository` 라는 클래스를 통해 앱 내에 저장하고 있습니다. 만약에 이것을 서버에 저장하도록 바꾸려면 어떻게 하면 될까요 ? 방법은 우리가 이제까지 작업했던 것과 똑같습니다. `Repository` 프로토콜을 준수하는 `ServerRepository` 라는 클래스를 정의합니다. 그리고 실제로 서버에 저장하는 기능을 구현합니다. 그리고 `AppDelegate` 에서 `UserDefaultRepository` 를 `ServerRepository` 로 바꿔주기만 하면 됩니다. 

```swift
class ServerRepository: Repository {
    func load() -> [ToDo] {...}
    func save(todos: [ToDo]) {...}
}

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    //container.register(Repository.self) { _ in UserDefaultRepository() }
    container.register(Repository.self) { _ in ServerRepository() }
    container.register(ToDoService.self) { c in
        let repository = c.resolve(Repository.self)!
        return ToDoServiceImpl.init(repository: repository)
    }
    return true
}
```

다른 코드를 수정할 필요가 있나요 ? 없죠. `ServerRepository` 는 `Repository` 프로토콜을 준수하고 있으니까요. 심지어 이미 구현되어 있는 `UserDefaultRepository` 클래스를 `수정하거나 삭제`할 필요도 없습니다. 사실, 기존에 있는 `레거시 코드`를 수정하는 것보다 새로 클래스를 구현하는 것이 더 나을 때가 생각보다 꽤 많습니다. 기존 코드의 `네이밍, 기능, 히스토리`를 모른 채로 수정했다가는 어떤 `Side effect`가 발생할 지 모르기 때문입니다. 이런 이유로 `프로토콜 지향 프로그래밍(Protocol Oriented Programming)`은 유지보수에 용이하고 확장성이 있는 앱을 구현하는데 필수적이라고 할 수 있을 것입니다.


## Conclusion
- `프로토콜 지향 프로그래밍(Protocol Oriented Programming)`은 프로토콜을 중심으로 코딩하라는 뜻입니다. 
- 완전히 새로운 패러다임이 아니라 기존의 `객체 지향 프로그래밍(Object Oriented Programming)`에서 프로토콜의 역할을 늘려서 중심적으로 사용하는 것을 말합니다. 즉, `POP는 Protocol을 적극적으로 활용하는 OOP` 라고 볼 수 있습니다. 
- `프로토콜 지향 프로그래밍(Protocol Oriented Programming)`에서는 구현 과정에서 `구현체보다 Protocol을 우선`으로 생각합니다. 
- 프로토콜을 사용해서 구현을 강제하고, 추상화하고 느슨하게 결합하면 애플리케이션의 유지보수에 용이하면서 유연하게 확장할 수 있습니다. 


## Reference

[https://let-us-go-2022-summer.vercel.app/](https://let-us-go-2022-summer.vercel.app/)				

[https://www.youtube.com/watch?v=q_mPAZB3RQY&list=LL&index=3&t=25s](https://www.youtube.com/watch?v=q_mPAZB3RQY&list=LL&index=3&t=25s)		

[https://github.com/iamchiwon/TheToDo](https://github.com/iamchiwon/TheToDo)			

[https://www.slideshare.net/ChiwonSong/20220716pop](https://www.slideshare.net/ChiwonSong/20220716pop)

[https://github.com/Swinject/Swinject](https://github.com/Swinject/Swinject)

[https://developer.apple.com/videos/play/wwdc2015/408/
](https://developer.apple.com/videos/play/wwdc2015/408/)









