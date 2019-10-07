//
//  InstanceViewController.swift
//  TestApp
//
//  Created by Thomas Böhm on 18.06.19.
//  Copyright © 2019 Thomas Böhm. All rights reserved.
//

import UIKit
import SceneKit

protocol RuleCreationDelegate {
    func didSelectRuleStart(for node: SCNNode)
    func didSelectRuleEnd(for endNode: SCNNode) -> SCNNode?
}

class InstanceViewController: UIViewController {

    var definitions = [Definition]()

    var arViewController: ARViewController!
    var instance: Instance!
    
    var delegate: RuleCreationDelegate?
    var ruleTrigger: TriggerDefinition?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    @IBAction func hideView(_ sender: UIBarButtonItem) {
        arViewController.containerView.alpha = 0.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arViewController = (navigationController!.parent as! ARViewController)
        
        tableView.dataSource = self
        tableView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let instance = instance as? TriggerInstance {
            self.title = instance.label ?? titleForType(instance.type)
            definitions = arViewController.definitions.filter { $0.triggerType == instance.type && $0.instId == instance.instId }
            
            if definitions.count == 0 && arViewController.rules.isEmpty {
                let msg = "Create a new Definition by tapping the +."
                let str = NSMutableAttributedString(string: msg)
                arViewController.userAdvices = str
            } else if definitions.count == 1 && arViewController.rules.isEmpty {
                let msg = "Now, you can select your created Trigger by tapping on the listed Definition."
                let str = NSMutableAttributedString(string: msg)
                arViewController.userAdvices = str
            }
            
        } else if let instance = instance as? ActionInstance {
            self.title = instance.label ?? titleForType(instance.type)
            definitions = arViewController.definitions.filter { $0.actionType == instance.type && $0.instId == instance.instId }
            
            if definitions.count == 0 && arViewController.rules.isEmpty {
                let msg = "Again, define a new Action Definition by tapping the +."
                let str = NSMutableAttributedString(string: msg)
                arViewController.userAdvices = str
            } else if definitions.count == 1 && arViewController.rules.isEmpty {
                let msg = "Finally, confirm your created Rule by tapping on the Action Definition in the List."
                let str = NSMutableAttributedString(string: msg)
                arViewController.userAdvices = str
            }
        }
 
        tableView.reloadData()
        checkEmptyTableView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDefinitions", let vc = segue.destination as? DefinitionViewController {
            vc.instance = instance
            vc.title = instance is TriggerInstance ? "Create new Trigger" : "Create new Action"
        }
    }
    
    private func checkEmptyTableView() {
        if definitions.count == 0 {
            tableView.isHidden = true
            if arViewController.rules.isEmpty {
                // no need for extra information due to given user advices
                emptyLabel.text = ""
            } else if instance is TriggerInstance {
                emptyLabel.text = "There are no Triggers created yet"
            } else {
                emptyLabel.text = "There are no Actions created yet"
            }
            emptyLabel.isHidden = false
        } else {
            tableView.isHidden = false
            emptyLabel.isHidden = true
        }
    }
    
    private func titleForType(_ type: Any) -> String {
        if let type = type as? TriggerType {
            switch type {
            case .button:
                return "Button"
            case .temperatureAndPressure:
                return "Temperature & Pressure"
            }
        }
        if let type = type as? ActionType {
            switch type {
            case .led:
                return "LED"
            case .player:
                return "Tune Player"
            }
        }
        return ""
    }
}

extension InstanceViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return definitions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
            return UITableViewCell()
        }
        
        cell.textLabel?.textColor = .white
        cell.textLabel?.text = definitions[indexPath.row].description
        cell.accessoryView = definitions[indexPath.row].isConnected ? DrawIcon.filledCircle : DrawIcon.circle
        
        if let definition = definitions[indexPath.row] as? ActionDefinition {
            if let color = definition.color {
                cell.textLabel?.textColor = color
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let definition = definitions[indexPath.row] as? TriggerDefinition {
            delegate?.didSelectRuleStart(for: instance.node!)
            ruleTrigger = definition

            let msg = "Next, tap on the Action with which you want to connect the Trigger."
            let str = NSMutableAttributedString(string: msg)
            str.addAttribute(.foregroundColor, value: #colorLiteral(red: 0.6091628671, green: 0.3471981585, blue: 0.7143893838, alpha: 1), range: NSRange(location: 17,length: 6))
            arViewController.userAdvices = str
            
        } else if let definition = definitions[indexPath.row] as? ActionDefinition {
            tableView.deselectRow(at: indexPath, animated: true)

            let ruleNode = delegate?.didSelectRuleEnd(for: instance.node!)

            if let trigger = ruleTrigger, let ruleNode = ruleNode {
                print("New Rule: \(String(describing: trigger)) --> \(String(describing: definition))")
                
                let rule = Rule(triggerId: trigger.id, actionId: definition.id, node: ruleNode)
                arViewController.rules.append(rule)
                arViewController.advertisedStrings.append(Parser.encodeRule(ruleId: rule.id,
                                                                            triggerId: rule.triggerId,
                                                                            actionId: rule.actionId))
                
                trigger.isConnected = true
                definition.isConnected = true

                ruleTrigger = nil
                
                arViewController.userAdvices = nil
                arViewController.infoLabel.superview?.superview?.isHidden = true
                tableView.reloadData()
            }
        }
    }
}
