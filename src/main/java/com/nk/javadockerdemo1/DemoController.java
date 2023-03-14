package com.nk.javadockerdemo1;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class DemoController {

	  @GetMapping("/message")
	  public String message() {
	    return "Hello from Java project inside container";
	  }
}