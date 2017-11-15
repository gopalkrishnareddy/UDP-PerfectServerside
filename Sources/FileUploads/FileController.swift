//
//  FileController.swift
//  PerfectAuthServer
//
//  Created by Yoel Lev on 10/8/17.
//
//


import Foundation
import PerfectLib
import PerfectHTTP
import StORM
import PerfectLib

//Will be executed in the background in a Synchronous execution
//let queue = DispatchQueue(label: "com.yoelev.simpleSyncQueues")

class FileController {
    
    
    static func uploadFile(data: [String:Any]) throws -> RequestHandler {
        return {
            request, response in
            
            print("In uploadFile ")
            
            // Context variable, which also initializes the "files" array
            var context = ["files":[[String:String]]()]
            
            // Process only if request.postFileUploads is populated
            if let uploads = request.postFileUploads, uploads.count > 0 {
                
                // iterate through the file uploads.
                for upload in uploads {
                    
                    // move file
                    let thisFile = File(upload.tmpFileName)
                    do {
                        let _ = try thisFile.moveTo(path: "./webroot/uploads/\(upload.fileName)", overWrite: true)
						
						//queue.sync {
						
						
						DispatchQueue.global().async {
							
							print("##### Parsing csv in a Synchronous Execution in the background ##### ")
							
							// readFile(filename: f)
							if let csvFile =  readCSVFile(name: upload.fileName) {
								parseCSVToClient(csv: csvFile)
							}
						}
						
							
						//}
						
                    } catch {
                        print(error)
                    }
                }
            }

            // Inspect the uploads directory contents
            let d = Dir("./webroot/uploads")
            do{
                try d.forEachEntry(closure: { f in
                    
					
                    
                    context["files"]?.append(["name":f])
                })
            } catch {
                print(error)
            }
            
            // Render the Mustache template, with context.
            response.render(template: "templates/index", context: context)
            response.completed()
        }
    }
	
	
	
	static func downloadFile(data: [String:Any]) throws -> RequestHandler {
		return {
			
			request, response in
			
			guard let fileName = request.urlVariables["fileName"] else {
					response.completed(status: .badRequest)
					print("Unable to download file, Bad request")
					return
			}

			print("Downloading file \(fileName)")
			
			do{
				
				
				let thisFile = File("./webroot/uploads/\(fileName)")
				print(thisFile.path)
				let contents = try thisFile.readString()
			
				response.setBody(string: "Downloading \(contents)...")
					.setHeader(.contentDisposition, value: "attachment; filename=\"\(fileName)\"")
          .setHeader(.contentType, value: "text/plain")
					.completed()
				
			}catch{
				print("Error Dwonloading file ")
				
			}
			
		
		}
	}
    
    
    
    
    static func readFile(filename:String){
        
        do {
            
            let thisFile = File("./webroot/uploads/\(filename)")
            try thisFile.open(.readWrite)
            
            let contents = try thisFile.readString()
            let csv = CSV(string: contents)
            
            print(csv.header)
            
        }catch{
            print("couldnt read file ")
        }
        
    }
    
    
    static func readCSVFile(name:String) -> CSV? {
        
        do {
            let csv = try CSV(name: "./webroot/uploads/\(name)", delimiter: "\r", encoding: String.Encoding.utf8, loadColumns: true)
            
            return csv
         
        } catch {
            // Error handling
            print("couldnt read file named: \(name)")
        }
 
        return nil
    }
    
    static func parseCSVToClient(csv:CSV){
        
        csv.enumerateAsArray { array in

            // Loop over elements and indexes in array.
            for field in array {
                
                let  arr = field.components(separatedBy: ",")
                    print(arr)
                }
                
            }
		print("########################")
		print("Finish Parsing file ")
		print("########################")
        }
        
        
}
    


