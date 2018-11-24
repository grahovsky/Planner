
import UIKit

class TaskDetailsController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellTaskDetail", for: indexPath) as! UITableViewCell
        
        cell.textLabel?.text = "тест"
        
        return cell
    }
    

    // вызывается после инициализации
    override func viewDidLoad() {
        super.viewDidLoad()



    }

    // вызывается, если не хватает памяти (чтобы очистить ресурсы)
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

